# frozen_string_literal: true

module GryphonNest
  module Compressors
    autoload :BrotliCompressor, 'gryphon_nest/compressors/brotli_compressor'
    autoload :GzipCompressor, 'gryphon_nest/compressors/gzip_compressor'

    class << self
      COMPRESSABLE_FILETYPES = %w[
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
      def can_compress?(file)
        file.size >= 20 && COMPRESSABLE_FILETYPES.include?(file.extname)
      end

      # return [Array<Object>]
      def create
        compressors = [GzipCompressor.new]

        require 'brotli'
        compressors.append(BrotliCompressor.new)
        compressors
      rescue LoadError
        compressors
      end
    end
  end
end
