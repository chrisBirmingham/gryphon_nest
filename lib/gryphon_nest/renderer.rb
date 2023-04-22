# frozen_string_literal: true

require 'htmlbeautifier'
require 'mustache'

module GryphonNest
  # Renders mustache templates to html
  class Renderer
    # @param layouts [Array]
    def initialize
      @layouts = {}
    end

    # @param template [String]
    # @param layout [String]
    # @param context [Hash]
    # @return [String]
    def render(template, layout, context)
      File.open(template) do |f|
        content = render_template(f.read, context)
        layout = get_template_layout(layout)

        unless layout.nil?
          context[:yield] = content
          content = render_template(layout, context)
        end

        HtmlBeautifier.beautify(content)
      end
    end

    private

    # @param content [String]
    # @param context [Hash]
    # @return [String]
    def render_template(content, context)
      Mustache.render(content, context)
    end

    # @param path [String]
    # @return [String|null]
    def get_template_layout(path)
      return @layouts[path] if @layouts.key?(path)

      return unless File.exist?(path)

      File.open(path) do |file|
        content = file.read
        @layouts[path] = content
        return content
      end
    end
  end
end
