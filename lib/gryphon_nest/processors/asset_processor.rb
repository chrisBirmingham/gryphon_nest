# frozen_string_literal: true

require 'fileutils'

module GryphonNest
  module Processors
    # Default file processor. Moves files from source to destination
    class AssetProcessor
      # @param src [Pathname]
      # @param dest [Pathname]
      def process(src, dest)
        dest.dirname.mkpath
        FileUtils.copy_file(src, dest)
      end

      # @param src [Pathname]
      # @return [Pathname]
      def dest_name(src)
        src.sub(CONTENT_DIR, BUILD_DIR)
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
