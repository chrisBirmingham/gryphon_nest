# frozen_string_literal: true

require 'fileutils'

module GryphonNest
  class AssetProcessor
    # @param dest_folder [String]
    def initialize(dest_folder)
      @dest_folder = dest_folder
    end

    # @param file [Pathname]
    def process(file)
      dest = dest_name(file)

      return unless file_modified?(file, dest)

      FileUtils.makedirs(dest.dirname)
      FileUtils.copy_file(file, dest)
    end

    private

    # @param src [Pathname]
    # @return [Pathname]
    def dest_name(src)
      parts = src.to_s.split('/')
      parts[0] = @dest_folder
      Pathname.new(parts.join('/'))
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
