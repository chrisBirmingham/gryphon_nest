# frozen_string_literal: true

require 'fileutils'

module GryphonNest
  module Processors
    # Default file processor. Moves files from source to destination
    class AssetProcessor
      # @param file [Pathname]
      # @return [Pathname]
      def process(file)
        dest = dest_name(file)

        if file_modified?(file, dest)
          puts "Copying #{file} to #{dest}"
          dest.dirname.mkpath
          FileUtils.copy_file(file, dest)
        end

        dest
      end

      private

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
