# frozen_string_literal: true

module GryphonNest
  class LayoutFile
    attr_reader :content, :mtime

    # @param content [String]
    # @param mtime [Time]
    def initialize(content, mtime)
      @content = content
      @mtime = mtime
    end

    # @return [LayoutFile|nil]
    def self.create
      path = Pathname.new(LAYOUT_FILE)

      new(File.read(path), path.mtime)
    rescue IOError, Errno::ENOENT
      nil
    end
  end
end
