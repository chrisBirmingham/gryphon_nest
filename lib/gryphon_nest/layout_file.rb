# frozen_string_literal: true

module GryphonNest
  # Wrapper class for operations performed on the layout.yaml file
  class LayoutFile
    # @param path [Pathname]
    def initialize(path)
      @path = path
      @content = nil
      @last_mtime = Time.now
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

      if @content.nil? || mod_time > @last_mtime
        @content = @path.read
        @last_mtime = mod_time
      end

      @content
    end
  end
end
