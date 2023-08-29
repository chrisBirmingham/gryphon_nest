# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'webrick'
require 'yaml'

module GryphonNest
  autoload :NotFoundError, 'gryphon_nest/not_found_error'
  autoload :Renderer, 'gryphon_nest/renderer'
  autoload :VERSION, 'gryphon_nest/version'

  class << self
    BUILD_DIR = '_site'
    CONTENT_DIR = 'content'
    DATA_DIR = 'data'
    ASSETS_DIR = 'assets'
    LAYOUT_DIR = 'layouts'
    TEMPLATE_EXT = '.mustache'

    # @raise [NotFoundError]
    def build_website
      raise NotFoundError, "Content directory doesn't exist" unless Dir.exist?(CONTENT_DIR)

      existing_files = []
      if Dir.exist?(BUILD_DIR)
        existing_files = filter_glob("#{BUILD_DIR}/**/*")
      else
        Dir.mkdir(BUILD_DIR)
      end

      existing_files = existing_files.difference(process_content)
      existing_files = existing_files.difference(copy_assets)
      cleanup(existing_files)
    end

    # @param port [Integer]
    def serve_website(port)
      puts "Running local server on #{port}"
      server = WEBrick::HTTPServer.new(Port: port, DocumentRoot: BUILD_DIR)
      # Trap ctrl c so we don't get the horrible stack trace
      trap('INT') { server.shutdown }
      server.start
    end

    private

    # @param template_name [String]
    # @return [Pathname]
    def get_output_name(template_name)
      dir = File.dirname(template_name)
      basename = File.basename(template_name, TEMPLATE_EXT)

      path = Pathname.new(dir)
      path = path.sub(CONTENT_DIR, BUILD_DIR)

      path = path.join(basename) if basename != 'index'

      path.join('index.html')
    end

    # @params path [String]
    # @return [Array]
    def filter_glob(path)
      Dir.glob(path).reject do |p|
        File.directory?(p)
      end
    end

    # @param path [String]
    # @param content [String]
    def save_html_file(path, content)
      dir = File.dirname(path)

      unless Dir.exist?(dir)
        puts "Creating #{dir}"
        Dir.mkdir(dir)
      end

      puts "Creating #{path}"
      File.write(path, content)
    end

    # @param src [Pathname, String]
    # @param dest [Pathname, String]
    # @return [Boolean]
    def can_create_html_file?(src, dest)
      return true unless File.exist?(dest)

      src_mtime = File.mtime(src)
      dest_mtime = File.mtime(dest)
      src_mtime > dest_mtime
    end

    # @param dest_file [Pathname, String]
    # @param context_file [Pathname, String]
    # @param context [Hash]
    # @return [Boolean]
    def context_updated?(dest_file, context_file, context)
      return true unless File.exist?(dest_file)

      dest_mtime = File.mtime(dest_file)
      context_mtime = File.mtime(context_file)

      return true if context_mtime > dest_mtime

      if context.key?('layout')
        layout_mtime = File.mtime(context['layout'])
        return true if layout_mtime > dest_mtime
      end

      false
    end

    # @param name [String]
    # @param context [Hash]
    # @return [Pathname, nil]
    # @raise [NotFoundError]
    def get_layout_file(name, context)
      path = Pathname.new(LAYOUT_DIR)

      if context.key?('layout')
        layout = context['layout']
        path = path.join(layout)

        raise NotFoundError, "#{name} requires layout file #{layout} but it doesn't exist or can't be read" unless File.exist?(path)

        return path
      end

      path = path.join('main.mustache')
      path if File.exist?(path)
    end

    # @param name [String]
    # @param path [String]
    # @return [Hash]
    def read_context_file(name, path)
      File.open(path) do |yaml|
        context = YAML.safe_load(yaml)
        context['layout'] = get_layout_file(name, context)
        context
      end
    end

    # @param name [String]
    # @return [String, nil]
    def get_context_file(name)
      basename = File.basename(name, TEMPLATE_EXT)

      Dir.glob("#{DATA_DIR}/#{basename}.{yaml,yml}") do |f|
        return f
      end
    end

    # @return [Array]
    def process_content
      created_files = []
      renderer = Renderer.new

      filter_glob("#{CONTENT_DIR}/**/*").each do |template|
        if File.extname(template) != TEMPLATE_EXT
          warn "Skipping non template file #{template}"
          next
        end

        context = {}
        dest_file = get_output_name(template)
        created_files << dest_file.to_s
        next unless can_create_html_file?(template, dest_file)

        context_file = get_context_file(template)
        unless context_file.nil?
          context = read_context_file(template, context_file)
          next unless context_updated?(dest_file, context_file, context)
        end

        content = renderer.render_file(template, context)
        save_html_file(dest_file, content)
      end

      created_files
    end

    # @param src [Pathname, String]
    # @param dest [Pathname, String]
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

        puts "Copying #{asset} to #{dest}"
        dest_dir = File.dirname(dest)
        FileUtils.makedirs(dest_dir)
        FileUtils.copy_file(asset, dest)
      end

      copied_files
    end

    # @param junk_files [Array]
    def cleanup(junk_files)
      junk_files.each do |f|
        puts "Deleting #{f}"
        FileUtils.remove_file(f)
      end
    end
  end
end
