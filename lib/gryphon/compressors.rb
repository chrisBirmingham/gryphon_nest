# frozen_string_literal: true

module Gryphon
  module Compressors
    autoload :BrotliCompressor, 'gryphon/compressors/brotli_compressor'
    autoload :GzipCompressor, 'gryphon/compressors/gzip_compressor'

    class << self
      COMPRESSABLE = %w[
        .html
        .htm
        .xhtml
        .txt
        .csv
        .css
        .js
        .mjs
        .md
        .xml
        .svg
      ].freeze

      # @param file [Pathname]
      # @return [Boolean]
      def compressable?(file) = file.size >= 40 && COMPRESSABLE.include?(file.extname)

      # return [Array<Object>]
      def create
        compressors = [GzipCompressor.new]

        begin
          require 'brotli'
          compressors << BrotliCompressor.new
        rescue LoadError
          # Do nothing
        end

        compressors
      end
    end
  end
end
