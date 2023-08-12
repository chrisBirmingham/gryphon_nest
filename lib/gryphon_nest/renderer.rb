# frozen_string_literal: true

require 'htmlbeautifier'
require 'mustache'

module GryphonNest
  # Renders mustache templates to html
  class Renderer < Mustache
    # @param options [Hash]
    def initialize(options = {})
      @layouts = {}
      super
    end

    # @param template [String]
    # @param context [Hash]
    # @return [String]
    def render_file(template, context)
      content = super

      if context.key?('layout')
        context['yield'] = content
        content = super(context['layout'], context)
      end

      HtmlBeautifier.beautify(content)
    end

    # @param name [String]
    # @return [String]
    def partial(name)
      return @layouts[name] if @layouts.key?(name)

      content = File.read(name)
      @layouts[name] = content
      content
    end
  end
end
