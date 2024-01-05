# frozen_string_literal: true

require 'htmlbeautifier'
require 'mustache'

module GryphonNest
  # Renders mustache templates to html
  class Renderer < Mustache
    # @param template [String]
    # @param context [Hash]
    # @return [String]
    def render_file(template, context = {})
      content = super

      layout ||= read_layout_file
      unless layout.empty?
        context['yield'] = content
        content = render(layout, context)
      end

      HtmlBeautifier.beautify(content)
    end

    # @param name [String]
    # @return [String]
    def partial(name)
      File.read(name)
    end

    private

    # @return [String]
    def read_layout_file
      layout_file = @options['layout_file']

      return '' unless File.exist?(layout_file)

      File.read(layout_file)
    end
  end
end
