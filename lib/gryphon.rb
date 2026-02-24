# frozen_string_literal: true

require 'fileutils'
require 'listen'
require 'pathname'
require 'webrick'

module Gryphon
  autoload :Compressors, 'gryphon_nest/compressors'
  autoload :Errors, 'gryphon_nest/errors'
  autoload :LayoutFile, 'gryphon_nest/layout_file'
  autoload :Logging, 'gryphon_nest/logging'
  autoload :Processors, 'gryphon_nest/processors'
  autoload :Renderers, 'gryphon_nest/renderers'
  autoload :VERSION, 'gryphon_nest/version'

  BUILD_DIR = '_site'
  CONTENT_DIR = 'content'
  TEMPLATE_EXT = '.mustache'
  LAYOUT_FILE = 'layout.mustache'

  class Nest
    # @param compress [Boolean]
    # @param force [Boolean]
    def initialize(compress, force)
      @processors = Processors.create
      @logger = Logging.create
      @force = force
      @compressors = compress ? Compressors.create : []
      @modifications = 0
    end

    # @raise [Errors::NotFoundError]
    def build
      unless Dir.exist?(CONTENT_DIR)
        raise Errors::NotFoundError, "Content directory doesn't exist in the current directory"
      end

      Dir.mkdir(BUILD_DIR) unless Dir.exist?(BUILD_DIR)

      existing_files = glob(BUILD_DIR, '{!.gz,!.br}')
      content_files = glob(CONTENT_DIR)
      processed_files = content_files.collect { |src| process_file(src) }
      files_to_delete = existing_files.difference(processed_files)
      files_to_delete.each { |file| delete_file(file) }

      @logger.info('No changes detected') if @modifications.zero? && files_to_delete.empty?
    end

    def clean
      FileUtils.remove_dir(BUILD_DIR, true)
      @logger.info('Removed build dir')
    end

    def watch
      @logger.info('Watching for content changes')

      # Bypass modification checks, we already know the files been changed
      @force = true

      only = [/^#{CONTENT_DIR}/, /^#{LAYOUT_FILE}$/]
      Listen.to('.', relative: true, only: only) do |modified, added, removed|
        modified.union(added).each { |file| process_changes(file) }

        removed.each { |file| process_changes(file, removal: true) }
      end.start
    end

    # @param port [Integer]
    def serve(port)
      @logger.info("Running local server on #{port}")
      server = WEBrick::HTTPServer.new(Port: port, DocumentRoot: BUILD_DIR)
      # Trap ctrl c so we don't get the horrible stack trace
      trap('INT') { server.shutdown }
      server.start
    end

    private

    # @param src [Pathname]
    # @return [Pathname]
    def process_file(src)
      processor = @processors[src.extname]
      dest = processor.dest_name(src)

      if @force || processor.file_modified?(src, dest)
        @modifications += 1
        msg = File.exist?(dest) ? 'Recreating' : 'Creating'
        @logger.info("#{msg} #{dest}")
        processor.process(src, dest)
        compress_file(dest)
      end

      dest
    end

    # @param file [Pathname]
    def compress_file(file)
      return if @compressors.empty?

      return unless Compressors.can_compress?(file)

      @logger.info("Compressing #{file}")
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
    rescue StandardError => e
      @logger.error(e.message)
    end

    # @params base [String]
    # @params match [String]
    # @return [Array<Pathname>]
    def glob(base, match = '')
      Pathname.glob("#{base}/**/*#{match}").reject(&:directory?)
    end

    # @param file [Pathname]
    def delete_file(file)
      @logger.info("Deleting #{file}")
      file.delete

      @compressors.each do |compressor|
        compressed_file = Pathname.new("#{file}#{compressor.extname}")
        next unless compressed_file.exist?

        @logger.info("Deleting #{compressed_file}")
        compressed_file.delete
      end
    end
  end
end
