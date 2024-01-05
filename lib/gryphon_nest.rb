# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'webrick'

module GryphonNest
  autoload :NotFoundError, 'gryphon_nest/not_found_error'
  autoload :Renderer, 'gryphon_nest/renderer'
  autoload :VERSION, 'gryphon_nest/version'
  autoload :AssetProcessor, 'gryphon_nest/processors/asset_processor'
  autoload :MustacheProcessor, 'gryphon_nest/processors/mustache_processor'

  BUILD_DIR = '_site'
  CONTENT_DIR = 'content'
  DATA_DIR = 'data'
  TEMPLATE_EXT = '.mustache'
  LAYOUT_FILE = 'layouts/main.mustache'

  class << self
    # @raise [NotFoundError]
    def build_website
      raise NotFoundError, "Content directory doesn't exist" unless Dir.exist?(CONTENT_DIR)

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

    # @return [Array]
    def process_content
      processed_files = []
      renderer = Renderer.new({'layout_file' => LAYOUT_FILE})

      processors = {
        TEMPLATE_EXT => MustacheProcessor.new(renderer)
      }
      processors.default = AssetProcessor.new

      glob("#{CONTENT_DIR}/**/*").each do |source_file|
        processor = processors[source_file.extname]
        processed_files << processor.process(source_file)
      end

      processed_files
    end

    # @params path [String]
    # @return [Array]
    def glob(path)
      Pathname.glob(path).reject(&:directory?)
    end

    # @param junk_files [Array]
    def delete_files(junk_files)
      junk_files.each do |f|
        puts "Deleting #{f}"
        FileUtils.remove_file(f)
      end
    end
  end
end
