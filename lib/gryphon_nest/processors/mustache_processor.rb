# frozen_string_literal: true

require 'htmlbeautifier'
require 'yaml'

module GryphonNest
  module Processors
    # Renders a Mustache template into a html file
    class MustacheProcessor
      # @param renderer [Renderers::MustacheRenderer]
      # @param layout_file [LayoutFile]
      def initialize(renderer, layout_file)
        @renderer = renderer
        @layout_file = layout_file
      end

      # @param src [Pathname]
      # @param dest [Pathname]
      # @raise [Errors::YamlError]
      # @raise [Errors::ParseError]
      def process(src, dest)
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

      # @param src [Pathname]
      # @param dest [Pathname]
      # @return [Boolean]
      def file_modified?(src, dest)
        return true unless dest.exist?

        mod_time = dest.mtime
        return true if src.mtime > mod_time

        path = context_file_name(src)
        return true if path.exist? && path.mtime > mod_time

        return false unless @layout_file.exist?

        @layout_file.mtime > mod_time
      end

      private

      # @param src [Pathname]
      # @return [Hash]
      # @raise [Errors::YamlError]
      def read_context(src)
        YAML.safe_load_file(context_file_name(src), symbolize_names: true)
      rescue IOError, Errno::ENOENT
        {}
      rescue Psych::SyntaxError => e
        raise Errors::YamlError, "Encountered error while reading context file. Reason: #{e.message}"
      end

      # @param src [Pathname]
      # @return [Pathname]
      def context_file_name(src)
        src.sub(CONTENT_DIR, DATA_DIR).sub_ext('.yaml')
      end

      # @param file [Pathname]
      # @param context [Hash]
      # @return [String]
      # @raise [Errors::ParseError]
      def build_output(file, context)
        content =
          if @layout_file.exist?
            context[:yield] = file.basename(TEMPLATE_EXT)
            @renderer.render(@layout_file.content, context)
          else
            @renderer.render_file(file, context)
          end

        HtmlBeautifier.beautify(content, stop_on_errors: true)
      rescue Mustache::Parser::SyntaxError => e
        raise Errors::ParseError, "Failed to process mustache template #{file}. Reason:\n#{e}"
      rescue RuntimeError => e
        raise Errors::ParseError, "Failed to beautify template output #{file}. Reason: #{e.message}"
      end

      # @param path [Pathname]
      # @param content [String]
      def write_file(path, content)
        path.dirname.mkpath
        path.write(content)
      end
    end
  end
end
