# frozen_string_literal: true

module GryphonNest
  module Processors
    class SassProcessor
      include Logging

      # @param src [Pathname]
      # @param dest [Pathname]
      def process(src, dest)
        return unless file_modified?(src, dest)

        msg = File.exist?(dest) ? 'Recreating' : 'Creating'
        log "#{msg} #{dest}"

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

      private

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
