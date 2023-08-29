# frozen_string_literal: true

require 'fileutils'
require 'pathname'
require 'webrick'
require 'yaml'

module GryphonNest
  autoload :NotFoundError, 'gryphon_nest/not_found_error'
  autoload :Renderer, 'gryphon_nest/renderer'
  autoload :Util, 'gryphon_nest/util'
  autoload :VERSION, 'gryphon_nest/version'

  class << self
    BUILD_DIR = '_site'
    CONTENT_DIR = 'content'
    DATA_DIR = 'data'
    ASSETS_DIR = 'assets'
    LAYOUT_DIR = 'layouts'
    TEMPLATE_EXT = '.mustache'
    DEFAULT_LAYOUT = Pathname.new("#{LAYOUT_DIR}/main.mustache")

    # @raise [NotFoundError]
    def build_website
      raise NotFoundError, "Content directory doesn't exist" unless Dir.exist?(CONTENT_DIR)

      existing_files = []
      if Dir.exist?(BUILD_DIR)
        existing_files = Util.glob("#{BUILD_DIR}/**/*", as_str: true)
      else
        Dir.mkdir(BUILD_DIR)
      end

      existing_files = existing_files.difference(process_content)
      existing_files = existing_files.difference(copy_assets)
      Util.cleanup(existing_files)
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

    # @param source_file [Pathname]
    # @return [Pathname]
    def get_output_name(source_file)
      dir = source_file.dirname
      basename = source_file.basename(TEMPLATE_EXT)
      path = dir.sub(CONTENT_DIR, BUILD_DIR)

      path = path.join(basename) if basename.to_s != 'index'

      path.join('index.html')
    end

    # @param path [Pathname]
    # @param content [String]
    def save_html_file(path, content)
      dir = path.dirname

      unless dir.exist?
        puts "Creating #{dir}"
        dir.mkdir
      end

      puts "Creating #{path}"
      path.write(content)
    end

    # @param source_file [Pathname]
    # @param dest_file [Pathname]
    # @param context_file [Pathname, nil]
    # @param context [Hash]
    # @return [Boolean]
    def resources_updated?(source_file, dest_file, context_file, context)
      return true if Util.file_updated?(source_file, dest_file)

      return true if !context_file.nil? && Util.file_updated?(context_file, dest_file)

      return false unless context.key?('layout')

      Util.file_updated?(context['layout'], dest_file)
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

        raise NotFoundError, "#{name} requires layout file #{layout} but it doesn't exist or can't be read" unless path.exist?

        return path
      end

      DEFAULT_LAYOUT if DEFAULT_LAYOUT.exist?
    end

    # @param path [Pathname, nil]
    # @return [Hash]
    def get_context(path)
      return {} if path.nil?

      File.open(path) do |yaml|
        YAML.safe_load(yaml)
      end
    end

    # @param name [Pathname]
    # @return [Pathname, nil]
    def get_context_file(name)
      basename = name.basename(TEMPLATE_EXT)

      Dir.glob("#{DATA_DIR}/#{basename}.{yaml,yml}") do |f|
        return Pathname.new(f)
      end
    end

    # @return [Array]
    def process_content
      created_files = []
      renderer = Renderer.new

      Util.glob("#{CONTENT_DIR}/**/*").each do |source_file|
        if source_file.extname != TEMPLATE_EXT
          warn "Skipping non template file #{template}"
          next
        end

        dest_file = get_output_name(source_file)
        created_files << dest_file.to_s
        context_file = get_context_file(source_file)
        context = get_context(context_file)
        context['layout'] = get_layout_file(source_file.basename, context)

        next if resources_updated?(source_file, dest_file, context_file, context)

        content = renderer.render_file(source_file, context)
        save_html_file(dest_file, content)
      end

      created_files
    end

    # @return [Array]
    def copy_assets
      return [] unless Dir.exist?(ASSETS_DIR)

      copied_files = []
      Util.glob("#{ASSETS_DIR}/**/*").each do |asset|
        dest = asset.sub(ASSETS_DIR, BUILD_DIR)
        copied_files << dest.to_s

        next unless Util.file_updated?(asset, dest)

        puts "Copying #{asset} to #{dest}"
        dest_dir = dest.dirname
        FileUtils.makedirs(dest_dir)
        FileUtils.copy_file(asset, dest)
      end

      copied_files
    end
  end
end
