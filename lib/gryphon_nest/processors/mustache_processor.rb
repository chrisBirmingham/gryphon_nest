# frozen_string_literal: true

require 'yaml'

module GryphonNest
  module Processors
    class MustacheProcessor
      # @param renderer [Renderers::MustacheRenderer]
      def initialize(renderer)
        @renderer = renderer
      end

      # @param file [Pathname]
      # @return [Pathname]
      # @raise [Errors::YamlError]
      def process(file)
        dest = dest_name(file)
        context = read_context(file)
        content = @renderer.render_file(file, context)
        write_file(dest, content)
        dest
      end

      private

      # @param src [Pathname]
      # @return [Pathname]
      def dest_name(src)
        dir = src.dirname
        path = dir.sub(CONTENT_DIR, BUILD_DIR)
        basename = src.basename(TEMPLATE_EXT)

        path = path.join(basename) if basename.to_s != 'index'

        path.join('index.html')
      end

      # @param src [Pathname]
      # @return [Hash]
      # @raise [Errors::YamlError]
      def read_context(src)
        basename = src.basename(TEMPLATE_EXT)
        path = "#{DATA_DIR}/#{basename}.yaml"
        YAML.safe_load_file(path)
      rescue IOError
        {}
      rescue Errno::ENOENT
        {}
      rescue Psych::SyntaxError => e
        raise Errors::YamlError, "Encountered error while reading context file. #{e.message}"
      end

      # @param path [Pathname]
      # @param content [String]
      def write_file(path, content)
        dir = path.dirname
        dir.mkpath
        puts "Creating #{path}"
        path.write(content)
      end
    end
  end
end
