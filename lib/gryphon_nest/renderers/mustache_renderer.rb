# frozen_string_literal: true

require 'mustache'

module GryphonNest
  module Renderers
    # Renders mustache templates to html
    class MustacheRenderer < Mustache

      # @param name [String]
      # @return [String]
      def partial(name)
        name = @context[:yield]
        path = "#{template_path}/#{name}.#{template_extension}"
        File.read(path)
      end
    end
  end
end

