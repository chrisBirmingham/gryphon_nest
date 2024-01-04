# frozen_string_literal: true

module GryphonNest
  class MustacheProcessor
    # @param renderer [Renderer]
    # @param dest_folder [String]
    # @param context_folder [String]
    def initialize(renderer, dest_folder, context_folder)
      @renderer = renderer
      @dest_folder = dest_folder
      @context_folder = context_folder
    end

    # @param file [Pathname]
    def process(file)
      dest = dest_name(file)
      content = @renderer.render_file(file)
      write_file(dest, content)
    end

    private

    # @param src [Pathname]
    # @return [Pathname]
    def dest_name(src)
      parts = src.to_s.split('/')
      parts[0] = @dest_folder
      path = Pathname.new(parts.join('/'))
      basename = src.basename('.mustache')

      path = path.join(basename) if basename.to_s != 'index'

      path.join('index.html')
    end

    # @param path [Pathname]
    # @param content [String]
    def write_file(path, content)
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