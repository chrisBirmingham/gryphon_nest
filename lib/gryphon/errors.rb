# frozen_string_literal: true

module Gryphon
  module Errors
    class NotFoundError < StandardError; end

    class ParseError < StandardError; end

    class YamlError < StandardError; end
  end
end
