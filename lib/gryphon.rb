# frozen_string_literal: true

require 'fileutils'
require 'listen'
require 'pathname'
require 'webrick'

module Gryphon
  autoload :Cli, 'gryphon/cli'
  autoload :Compressors, 'gryphon/compressors'
  autoload :Errors, 'gryphon/errors'
  autoload :LayoutFile, 'gryphon/layout_file'
  autoload :Logging, 'gryphon/logging'
  autoload :Processors, 'gryphon/processors'
  autoload :Renderers, 'gryphon/renderers'
  autoload :VERSION, 'gryphon/version'

  BUILD_DIR = '_site'
  CONTENT_DIR = 'content'
  TEMPLATE_EXT = '.mustache'
  LAYOUT_FILE = 'layout.mustache'

  class Nest
    include Logging

    # @param processors [Array<Object>]
    # @param compressors [Array<Object>]
    # @param force [Boolean]
    def initialize(processors, compressors, force)
      @processors = processors
      @compressors = compressors
      @force = force
      @modifications = 0
    end

    # @raise [Errors::GryphonError]
    def build
      unless Dir.exist?(CONTENT_DIR)
        raise Errors::NotFoundError, "Content directory doesn't exist in the current directory"
      end

      FileUtils.mkdir_p(BUILD_DIR)
      existing_files = glob(BUILD_DIR, '{!.gz,!.br}')
      content_files = glob(CONTENT_DIR)
      processed_files = content_files.collect { |src| process_file(src) }
      files_to_delete = existing_files.difference(processed_files)
      files_to_delete.each { |file| delete_file(file) }

      log('No changes detected') if @modifications.zero? && files_to_delete.empty?
    end

    def clean
      FileUtils.remove_dir(BUILD_DIR, true)
      log('Removed build dir')
    end

    # @param port [Integer]
    # @param monitor [Boolean]
    def serve(port, monitor)
      watch if monitor

      log("Running local server on #{port}")
      server = WEBrick::HTTPServer.new(Port: port, DocumentRoot: BUILD_DIR, AccessLog: [])
      # Trap ctrl c so we don't get the horrible stack trace
      trap('INT') { server.shutdown }
      server.start
    end

    private

    def watch
      log('Watching for content changes')

      # Bypass modification checks, we already know the files been changed
      @force = true

      only = [/^#{CONTENT_DIR}/, /^#{LAYOUT_FILE}$/]
      Listen.to('.', relative: true, only: only) do |modified, added, removed|
        modified.union(added).each { |file| process_changes(file) }

        removed.each { |file| process_changes(file, removal: true) }
      end.start
    end

    # @param src [Pathname]
    # @return [Pathname]
    # @raise [Errors::GryphonError]
    def process_file(src)
      processor = @processors[src.extname]
      dest = processor.dest_name(src)

      if @force || processor.file_modified?(src, dest)
        @modifications += 1
        msg = File.exist?(dest) ? 'Recreating' : 'Creating'
        log("#{msg} #{dest}")
        processor.process(src, dest)
        compress_file(dest)
      end

      dest
    end

    # @param file [Pathname]
    def compress_file(file)
      return if @compressors.empty?

      return unless Compressors.compressable?(file)

      log("Compressing #{file}")
      @compressors.each { |compressor| compressor.compress(file) }
    end

    # @param src [String]
    # @param removal [Boolean]
    def process_changes(src, removal: false)
      if src == LAYOUT_FILE
        glob(CONTENT_DIR, TEMPLATE_EXT).each { |file| process_file(file) }
      else
        path = Pathname(src)

        if removal
          path = @processors[path.extname].dest_name(path)
          delete_file(path)
        else
          process_file(path)
        end
      end
    rescue Errors::GryphonError => e
      log(e.message, Logger::ERROR)
    end

    # @params base [String]
    # @params match [String]
    # @return [Array<Pathname>]
    def glob(base, match = '') = Pathname.glob("#{base}/**/*#{match}").reject(&:directory?)

    # @param file [Pathname]
    def delete_file(file)
      log("Deleting #{file}")
      file.delete

      @compressors.each do |compressor|
        compressed_file = Pathname("#{file}#{compressor.extname}")
        next unless compressed_file.exist?

        log("Deleting #{compressed_file}")
        compressed_file.delete
      end
    end
  end
end
