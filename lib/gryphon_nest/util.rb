# frozen_string_literal: true

require 'pathname'

module GryphonNest
  class Util
    # @params path [String]
    # @param as_str [Boolean]
    # @return [Array]
    def self.glob(path, as_str: false)
      files = Dir.glob(path).reject do |p|
        File.directory?(p)
      end

      return files if as_str

      files.map do |f|
        Pathname.new(f)
      end
    end

    # @param junk_files [Array]
    def self.cleanup(junk_files)
      junk_files.each do |f|
        puts "Deleting #{f}"
        FileUtils.remove_file(f)
      end
    end

    # @param src [Pathname]
    # @param dest [Pathname]
    # @return [Boolean]
    def self.file_updated?(src, dest)
      return true unless dest.exist?

      src.mtime > dest.mtime
    end
  end
end
