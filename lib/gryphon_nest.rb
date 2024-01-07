# frozen_string_literal: true

require 'pathname'
require 'webrick'

module GryphonNest
  autoload :Errors, 'gryphon_nest/errors'
  autoload :Processors, 'gryphon_nest/processors'
  autoload :Renderers, 'gryphon_nest/renderers'
  autoload :VERSION, 'gryphon_nest/version'

  BUILD_DIR = '_site'
  CONTENT_DIR = 'content'
  DATA_DIR = 'data'
  TEMPLATE_EXT = '.mustache'
  LAYOUT_FILE = 'layouts/main.mustache'

  class << self
    # @raise [Errors::NotFoundError]
    def build_website
      raise Errors::NotFoundError, "Content directory doesn't exist in current directory" unless Dir.exist?(CONTENT_DIR)

      existing_files = []
      if Dir.exist?(BUILD_DIR)
        existing_files = glob("#{BUILD_DIR}/**/*")
      else
        Dir.mkdir(BUILD_DIR)
      end

      existing_files = existing_files.difference(process_content)
      delete_files(existing_files)
    end

    # @param port [Integer]
    def serve_website(port)
      puts "Running local server on #{port}"
      server = WEBrick::HTTPServer.new(Port: port, DocumentRoot: BUILD_DIR)
      # Trap ctrl c so we don't get the horrible stack trace
      trap('INT') { server.shutdown }
      server.start
    end

    private

    # @return [Array<Pathname>]
    def process_content
      processed_files = []
      renderer = Renderers::MustacheRenderer.new({ 'layout_file' => LAYOUT_FILE })
      asset_processor = Processors::AssetProcessor.new

      processors = {
        TEMPLATE_EXT => Processors::MustacheProcessor.new(renderer)
      }

      glob("#{CONTENT_DIR}/**/*").each do |source_file|
        processor = processors.fetch(source_file.extname, asset_processor)
        processed_files << processor.process(source_file)
      end

      processed_files
    end

    # @params path [String]
    # @return [Array<Pathname>]
    def glob(path)
      Pathname.glob(path).reject(&:directory?)
    end

    # @param junk_files [Array<Pathname>]
    def delete_files(junk_files)
      junk_files.each do |f|
        puts "Deleting #{f}"
        f.delete
      end
      nil
    end
  end
end
