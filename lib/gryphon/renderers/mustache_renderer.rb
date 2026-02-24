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
        name = @context[:yield]
        path = "#{template_path}/#{name}.#{template_extension}"
        docs = yaml_parse(name, File.read(path))

        content = docs[0]

        unless docs[1].nil?
          context.push(docs[0])
          content = docs[1]
        end

        content
      end

      private

      # @param name [String]
      # @param content [String]
      # @return [Array]
      def yaml_parse(name, content)
        docs = []

        YAML.safe_load_stream(content) do |doc|
          docs << doc
        end

        docs
      rescue Psych::SyntaxError => e
        raise Errors::YamlError, "Encountered error while reading file #{name}. Reason: #{e.message}"
      end
    end
  end
end
