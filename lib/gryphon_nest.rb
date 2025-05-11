# frozen_string_literal: true

require 'listen'
require 'pathname'
require 'webrick'

module GryphonNest
  autoload :Errors, 'gryphon_nest/errors'
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
    def initialize
      @processors = Processors::ProcessorRegistry.new
      @processors.build
      @logger = Logging.create
    end

    # @raise [Errors::NotFoundError]
    def build
      raise Errors::NotFoundError, "Content directory doesn't exist in the current directory" unless Dir.exist?(CONTENT_DIR)

      Dir.mkdir(BUILD_DIR) unless Dir.exist?(BUILD_DIR)

      existing_files = glob("#{BUILD_DIR}/**/*")
      content_files = glob("#{CONTENT_DIR}/**/*")
      existing_files = existing_files.difference(process_files(content_files))
      delete_files(existing_files)
    end

    def watch
      @logger.info('Watching for content changes')
      listener = Listen.to(CONTENT_DIR, relative: true) do |modified, added, removed|
        mod = modified.union(added).collect do |file|
          Pathname(file)
        end

        process_files(mod)

        mod = removed.collect do |file|
          path = Pathname(file)
          @processors[path.extname].dest_name(path)
        end

        delete_files(mod)
      end

      listener.start
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

    # @param files [Array<Pathname>]
    # @return [Array<Pathname>]
    def process_files(files)
      files.collect do |src|
        processor = @processors[src.extname]
        dest = processor.dest_name(src)

        if processor.file_modified?(src, dest)
          msg = File.exist?(dest) ? 'Recreating' : 'Creating'
          @logger.info("#{msg} #{dest}")
          processor.process(src, dest)
        end

        dest
      end
    end

    # @params path [String]
    # @return [Array<Pathname>]
    def glob(path)
      Pathname.glob(path).reject(&:directory?)
    end

    # @param junk_files [Array<Pathname>]
    def delete_files(junk_files)
      junk_files.each do |f|
        @logger.info("Deleting #{f}")
        f.delete
      end
      nil
    end
  end
end
