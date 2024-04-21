# frozen_string_literal: true

require 'htmlbeautifier'
require 'mustache'

module GryphonNest
  module Renderers
    # Renders mustache templates to html
    class MustacheRenderer < Mustache
      # @param template [String]
      # @param context [Hash]
      # @return [String]
      def render_file(template, context = {})
        content = super
        HtmlBeautifier.beautify(content)
      end

      # @param name [String]
      # @return [String]
      def partial(name)
        content = File.read(name)
        layout ||= read_layout_file
        layout.empty? ? content : layout.sub(/{{{\s*yield\s*}}}/, content) 
      end

      private

      # @return [String]
      def read_layout_file
        File.read(LAYOUT_FILE)
      rescue IOError, Errno::ENOENT
        ''
      end
    end
  end
end
