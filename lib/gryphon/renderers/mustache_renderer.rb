# frozen_string_literal: true

require 'mustache'
require 'yaml'

module Gryphon
  module Renderers
    # Class to override default Mustache behavior
    class MustacheRenderer < Mustache
      # @param _name [String]
      # @return [String]
      # @raise [Psych::SyntaxError]
      def partial(_name)
        name = context[:yield]
        path = "#{template_path}/#{name}.#{template_extension}"
        docs = YAML.safe_load_stream(File.read(path), filename: name)

        content = docs[1] || docs[0]

        context.push(docs[0]) unless docs[1].nil?

        content
      end
    end
  end
end
