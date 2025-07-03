# frozen_string_literal: true

module GryphonNest
  class LayoutFile
    # @param path [Pathname]
    def initialize(path)
      @path = path
      @content = nil
      @last_mtime = Time.now

      if @path.exist?
        @content = @path.read
        @last_mtime = @path.mtime
      end
    end

    # @return [Boolean]
    def exist?
      @path.exist?
    end

    # @return [Time]
    def mtime
      @path.mtime
    end

    # @return [String]
    def content
      mod_time = mtime
      return @content if @last_mtime == mod_time

      @content = @path.read
      @last_mtime = mod_time
      @content
    end
  end
end
