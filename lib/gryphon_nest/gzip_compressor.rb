# frozen_string_literal: true

require 'zlib'

module GryphonNest
  class GzipCompressor
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

    # @param file [Pathname]
    def compress(file)
      compressed = "#{file}.gz"

      Zlib::GzipWriter.open(compressed, Zlib::BEST_COMPRESSION) do |gz|
        gz.mtime = file.mtime
        gz.orig_name = file.to_s
        gz.write IO.binread(file)
      end
    end
  end
end
