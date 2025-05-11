# frozen_string_literal: true

require 'htmlbeautifier'
require 'yaml'

module GryphonNest
  module Processors
    # Renders a Mustache template into a html file
    class MustacheProcessor
      # @param renderer [Renderers::MustacheRenderer]
      def initialize(renderer)
        @renderer = renderer
      end

      # @param src [Pathname]
      # @param dest [Pathname]
      # @raise [Errors::YamlError]
      # @raise [Errors::ParseError]
      def process(src, dest)
        @layout ||= read_layout_file

        context = read_context(src)
        content = build_output(src, context)
        write_file(dest, content)
      end

      # @param src [Pathname]
      # @return [Pathname]
      def dest_name(src)
        dir = src.dirname
        path = dir.sub(CONTENT_DIR, BUILD_DIR)
        basename = src.basename(TEMPLATE_EXT)

        path = path.join(basename) if basename.to_s != 'index'

        path.join('index.html')
      end

      # @param _src [Pathname]
      # @param _dest [Pathname]
      # @return [Boolean]
      def file_modified?(_src, _dest)
        true
      end

      private

      # @param src [Pathname]
      # @return [Hash]
      # @raise [Errors::YamlError]
      def read_context(src)
        path = src.sub(CONTENT_DIR, DATA_DIR).sub_ext('.yaml')
        YAML.safe_load_file(path, symbolize_names: true)
      rescue IOError, Errno::ENOENT
        {}
      rescue Psych::SyntaxError => e
        raise Errors::YamlError, "Encountered error while reading context file. Reason: #{e.message}"
      end

      # @param file [Pathname]
      # @param context [Hash]
      # @return [String]
      # @raise [Errors::ParseError]
      def build_output(file, context)
        content =
          if @layout.empty?
            @renderer.render_file(file, context)
          else
            context[:yield] = file.basename(TEMPLATE_EXT)
            @renderer.render(@layout, context)
          end

        HtmlBeautifier.beautify(content, stop_on_errors: true)
      rescue Mustache::Parser::SyntaxError => e
        raise Errors::ParseError, "Failed to process mustache template #{file}.\nReason: #{e}"
      rescue RuntimeError => e
        raise Errors::ParseError, "Failed to beautify template output #{file}. Reason: #{e.message}"
      end

      # @param path [Pathname]
      # @param content [String]
      def write_file(path, content)
        path.dirname.mkpath
        path.write(content)
      end

      # @return [String]
      def read_layout_file
        File.read(LAYOUT_FILE)
      rescue IOError, Errno::ENOENT
        ''
      end
    end
  end
end
