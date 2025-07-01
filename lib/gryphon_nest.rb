# frozen_string_literal: true

require 'fileutils'
require 'listen'
require 'pathname'
require 'webrick'

module GryphonNest
  autoload :Errors, 'gryphon_nest/errors'
  autoload :GzipCompressor, 'gryphon_nest/gzip_compressor'
  autoload :Logging, 'gryphon_nest/logging'
  autoload :Processors, 'gryphon_nest/processors'
  autoload :Renderers, 'gryphon_nest/renderers'
  autoload :VERSION, 'gryphon_nest/version'

  BUILD_DIR = '_site'
  CONTENT_DIR = 'content'
  DATA_DIR = 'data'
  TEMPLATE_EXT = '.mustache'
  LAYOUT_FILE = 'layout.mustache'

  class Nest
    # @return [GzipCompressor, nil]
    attr_writer :compressor

    # @param force [Boolean]
    def initialize(force)
      @processors = Processors.create
      @logger = Logging.create
      @force = force
      @compressor = nil
    end

    # @raise [Errors::NotFoundError]
    def build
      raise Errors::NotFoundError, "Content directory doesn't exist in the current directory" unless Dir.exist?(CONTENT_DIR)

      Dir.mkdir(BUILD_DIR) unless Dir.exist?(BUILD_DIR)

      existing_files = glob(BUILD_DIR, '[!.gz]')
      content_files = glob(CONTENT_DIR)
      processed_files = content_files.collect { |src| process_file(src) }
      existing_files.difference(processed_files).each { |file| delete_file(file) }
    end

    def clean
      FileUtils.remove_dir(BUILD_DIR, true)
      @logger.info('Removed build dir')
    end

    def watch
      @logger.info('Watching for content changes')

      # Bypass modification checks, we already know the files been changed
      @force = true

      only = [/^#{CONTENT_DIR}/, /^#{DATA_DIR}/, /^#{LAYOUT_FILE}$/]
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
        msg = File.exist?(dest) ? 'Recreating' : 'Creating'
        @logger.info("#{msg} #{dest}")
        processor.process(src, dest)
        compress_file(dest)
      end

      dest
    end

    # @param file [Pathname]
    def compress_file(file)
      return unless @compressor.is_a?(GzipCompressor)

      @logger.info("Compressing #{file}")
      unless @compressor.can_compress?(file)
        @logger.info("Skipping #{file}")
        return
      end

      @compressor.compress(file)
    end

    # @param src [Pathname]
    # @param removal [Boolean]
    def process_changes(src, removal: false)
      if src == LAYOUT_FILE
        glob(CONTENT_DIR, TEMPLATE_EXT).each { |file| process_file(file) }
      else
        path = Pathname(src)

        if src.start_with?(DATA_DIR)
          process_data_file(path)
        elsif removal
          path = @processors[path.extname].dest_name(path)
          delete_file(path)
        else
          process_file(path)
        end
      end
    end

    # @param src [Pathname]
    # @return [Pathname]
    def process_data_file(src)
      src = src.sub(DATA_DIR, CONTENT_DIR).sub_ext(TEMPLATE_EXT)

      return unless src.exist?

      process_file(src)
    end

    # @params base [String]
    # @params match [String]
    # @return [Array<Pathname>]
    def glob(base, match = '')
      Pathname.glob("#{base}/**/*#{match}").reject(&:directory?)
    end

    # @param file [Pathname]
    def delete_file(file)
      [file, Pathname("#{file}.gz")].each do |f|
        next unless f.exist?

        @logger.info("Deleting #{f}")
        f.delete
      end
    end
  end
end
