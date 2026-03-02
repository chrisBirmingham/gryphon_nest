# frozen_string_literal: true

module Gryphon
  module Errors
    class GryphonError < StandardError; end

    class NotFoundError < GryphonError; end

    class ParseError < GryphonError; end
  end
end
