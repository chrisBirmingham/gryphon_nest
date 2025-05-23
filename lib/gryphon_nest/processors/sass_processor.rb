# frozen_string_literal: true

require 'sass-embedded'

module GryphonNest
  module Processors
    class SassProcessor
      # @param src [Pathname]
      # @param dest [Pathname]
      # @raise [Errors::ParseError]
      def process(src, dest)
        result = Sass.compile(src)
        File.write(dest, result.css)
      rescue Sass::CompileError => e
        raise Errors::ParseError, "Failed to process sass style sheet #{src}. Reason:\n#{e.full_message}"
      end

      # @param src [Pathname]
      # @return [Pathname]
      def dest_name(src)
        src.sub(CONTENT_DIR, BUILD_DIR).sub_ext('.css')
      end

      # @param src [Pathname]
      # @param des [Pathname]
      # @return [Boolean]
      def file_modified?(src, dest)
        return true unless dest.exist?

        src.mtime > dest.mtime
      end
    end
  end
end
