# frozen_string_literal: true

module GryphonNest
  module Processors
    class SassProcessor
      # @param src [Pathname]
      # @param dest [Pathname]
      def process(src, dest)
        result = Sass.compile(src)
        File.write(dest, result.css)
      end

      # @param src [Pathname]
      # @return [Pathname]
      def dest_name(src)
        dir = src.dirname
        path = dir.sub(CONTENT_DIR, BUILD_DIR)
        path.join(src.basename).sub_ext('.css')
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
