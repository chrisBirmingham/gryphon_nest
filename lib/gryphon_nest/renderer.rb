# frozen_string_literal: true

require 'htmlbeautifier'
require 'mustache'

module GryphonNest
  class Renderer
    # @param layouts [Array]
    def initialize(layouts)
      @layouts = layouts
    end

    # @param path [String]
    # @param context [Hash]
    # @return [String]
    def render(path, context)
      File.open(path) do |f|
        content = render_template(f.read, context)
        layout = get_template_layout(path, context)
        context[:yield] = content
        content = render_template(layout, context)
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

    # @param name [String]
    # @param template_data [Hash]
    # @return [String]
    def get_template_layout(name, context)
      if context.key?(:layout)
        val = context[:layout]

        raise "#{name} requires layout file #{val} but it isn't a known layout" unless @layouts.key?(val)

        @layouts[val]
      else
        @layouts.fetch('main', '{{{yield}}}')
      end
    end
  end
end
