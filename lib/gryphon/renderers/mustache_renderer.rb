# frozen_string_literal: true

require 'mustache'
require 'yaml'

module Gryphon
  module Renderers
    # Class to override default Mustache behavior
    class MustacheRenderer < Mustache
      # @param _name [String]
      # @return [String]
      def partial(_name)
        context[:yield]
      end
    end
  end
end
