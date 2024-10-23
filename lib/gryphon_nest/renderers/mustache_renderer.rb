# frozen_string_literal: true

require 'mustache'

module GryphonNest
  module Renderers
    # Class to override default Mustache behavior
    class MustacheRenderer < Mustache

      # @param _name [String]
      # @return [String]
      def partial(_name)
        name = @context[:yield]
        path = "#{template_path}/#{name}.#{template_extension}"
        File.read(path)
      end
    end
  end
end
