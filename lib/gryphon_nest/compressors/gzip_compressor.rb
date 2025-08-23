# frozen_string_literal: true

require 'zlib'

module GryphonNest
  module Compressors
    class GzipCompressor
      def extname
        '.gz'
      end

      # @param file [Pathname]
      def compress(file)
        compressed = "#{file}#{extname}"

        Zlib::GzipWriter.open(compressed, Zlib::BEST_COMPRESSION) do |gz|
          gz.mtime = file.mtime
          gz.orig_name = file.to_s
          gz.write IO.binread(file)
        end
      end
    end
  end
end
