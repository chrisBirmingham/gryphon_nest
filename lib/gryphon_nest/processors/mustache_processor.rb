# frozen_string_literal: true

require 'yaml'

module GryphonNest
  class MustacheProcessor
    # @param renderer [Renderer]
    def initialize(renderer)
      @renderer = renderer
    end

    # @param file [Pathname]
    # @return [Pathname]
    def process(file)
      dest = dest_name(file)
      context = read_context(file) 
      content = @renderer.render_file(file, context)
      write_file(dest, content)
      dest
    end

    private

    # @param src [Pathname]
    # @return [Pathname]
    def dest_name(src)
      dir = src.dirname
      path = dir.sub(CONTENT_DIR, BUILD_DIR)
      basename = src.basename(TEMPLATE_EXT)

      path = path.join(basename) if basename.to_s != 'index'

      path.join('index.html')
    end

    # @param src [Pathname]
    # @return [Hash]
    def read_context(src)
      basename = src.basename(TEMPLATE_EXT)
      path = Pathname.new("#{DATA_DIR}/#{basename}.yaml")

      return {} unless path.exist?

      File.open(path) do |yaml|
        YAML.safe_load(yaml)
      end
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
