# frozen_string_literal: true

require 'fileutils'
require 'htmlbeautifier'
require 'mustache'
require 'pathname'
require 'webrick'
require 'yaml'

module GryphonNest
  autoload :VERSION, 'gryphon_nest/version'

  class << self
    BUILD_DIR = '_site'
    CONTENT_DIR = 'content'
    DATA_DIR = 'data'
    ASSETS_DIR = 'assets'
    LAYOUT_DIR = 'layouts'
    TEMPLATE_EXT = '.mustache'

    # @param template_name [String]
    # @return [String]
    def get_output_name(template_name)
      dir = File.dirname(template_name)
      basename = File.basename(template_name, TEMPLATE_EXT)

      path = Pathname.new(dir)
      path = path.sub(CONTENT_DIR, BUILD_DIR)

      path = path.join(basename) if basename != 'index'

      path = path.join('index.html')
      path.to_s
    end

    # @param name [String]
    # @param layouts [Hash]
    # @param template_data [Hash]
    # @return [String]
    def get_template_layout(name, layouts, template_data)
      if template_data.key?(:layout)
        val = template_data[:layout]

        raise "#{name} requires layout file #{val} but it isn't a known layout" unless layouts.key?(val)

        layouts[val]
      else
        layouts.fetch('main', '{{{yield}}}')
      end
    end

    # @param name [String]
    # @param content [String]
    # @param layouts [Hash]
    # @param data [Hash]
    # @return [String]
    def render_template(name, content, layouts, data)
      key = File.basename(name, TEMPLATE_EXT)
      template_data = data.fetch(key, {})

      content = Mustache.render(content, template_data)

      layout = get_template_layout(name, layouts, template_data)
      template_data[:yield] = content
      Mustache.render(layout, template_data)
    end

    # @params path [String]
    # @return [Array]
    def filter_glob(path)
      Dir.glob(path).reject do |p|
        File.directory?(p)
      end
    end

    # @param layouts [Hash]
    # @param data [Hash]
    # @return [Array]
    def process_content(layouts, data)
      created_files = []

      filter_glob("#{CONTENT_DIR}/**/*").each do |template|
        if File.extname(template) != TEMPLATE_EXT
          puts "Skipping non template file #{template}"
          next
        end

        File.open(template) do |f|
          content = render_template(template, f.read, layouts, data)
          content = HtmlBeautifier.beautify(content)
          html_file = get_output_name(template)

          dir = File.dirname(html_file)

          unless Dir.exist?(dir)
            puts "Creating #{dir}"
            Dir.mkdir(dir)
          end

          File.write(html_file, content)
          puts "Creating #{html_file}"

          created_files << html_file
        end
      end

      created_files
    end

    # @param src [String]
    # @param dest [String]
    # @return [Boolean]
    def can_copy_asset?(src, dest)
      return true unless File.exist?(dest)

      File.mtime(src) > File.mtime(dest)
    end

    # @return [Array]
    def copy_assets
      return [] unless Dir.exist?(ASSETS_DIR)

      copied_files = []
      filter_glob("#{ASSETS_DIR}/**/*").each do |asset|
        dest = Pathname.new(asset)
        dest = dest.sub(ASSETS_DIR, BUILD_DIR)
        copied_files << dest.to_s

        next unless can_copy_asset?(asset, dest)

        dest_dir = File.dirname(dest)
        FileUtils.makedirs(dest_dir)
        FileUtils.copy_file(asset, dest)
        puts "Copying #{asset} to #{dest}"
      end

      copied_files
    end

    # @return [Hash]
    def read_layout_files
      return {} unless Dir.exist?(LAYOUT_DIR)

      layouts = {}

      Dir.glob("#{LAYOUT_DIR}/*#{TEMPLATE_EXT}") do |f|
        key = File.basename(f, TEMPLATE_EXT)
        layouts[key] = File.read(f)
      end

      layouts
    end

    # @param file [String]
    # @return [Hash]
    def read_yaml(file)
      File.open(file) do |yaml|
        YAML.safe_load(yaml)
      end
    end

    # @return [Hash]
    def read_data_files
      return {} unless Dir.exist?(DATA_DIR)

      data = {}

      Dir.glob("#{DATA_DIR}/*.{yaml,yml}") do |f|
        key = File.basename(f, '.*')
        data[key] = read_yaml(f)
      end

      data
    end

    # @param junk_files [Array]
    def cleanup(junk_files)
      junk_files.each do |f|
        puts "Deleting #{f}"
        FileUtils.remove_file(f)
      end
    end

    def build_website
      raise "Content directory doesn't exist" unless Dir.exist?(CONTENT_DIR)

      existing_files = []
      if Dir.exist?(BUILD_DIR)
        existing_files = filter_glob("#{BUILD_DIR}/**/*")
      else
        Dir.mkdir(BUILD_DIR)
      end

      data = read_data_files
      layouts = read_layout_files
      existing_files = existing_files.difference(process_content(layouts, data))
      existing_files = existing_files.difference(copy_assets)
      cleanup(existing_files)
    end

    # @param port [Integer]
    def serve_website(port)
      put "Running local server on #{port}"
      server = WEBrick::HTTPServer.new(Port: port, DocumentRoot: BUILD_DIR)
      # Trap ctrl c so we don't get the horrible stack trace
      trap('INT') { server.shutdown }
      server.start
    end
  end
end
