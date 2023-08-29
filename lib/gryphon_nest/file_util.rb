# frozen_string_literal: true

require 'fileutils'
require 'pathname'

module GryphonNest
  class FileUtil
    # @params path [String]
    # @return [Array]
    def self.glob(path)
      files = Dir.glob(path).reject do |p|
        File.directory?(p)
      end

      files.map do |f|
        Pathname.new(f)
      end
    end

    # @param junk_files [Array]
    def self.delete(junk_files)
      junk_files.each do |f|
        puts "Deleting #{f}"
        FileUtils.remove_file(f)
      end
    end

    # @param src [Pathname]
    # @param dest [Pathname]
    # @return [Boolean]
    def self.file_newer?(src, dest)
      return true unless dest.exist?

      src.mtime > dest.mtime
    end

    # @param path [Pathname]
    # @param content [String]
    def self.write_file(path, content)
      dir = path.dirname

      unless dir.exist?
        puts "Creating #{dir}"
        dir.mkdir
      end

      puts "Creating #{path}"
      path.write(content)
    end
  end
end
