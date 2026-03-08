# frozen_string_literal: true

require 'zlib'

module Gryphon
  module Compressors
    # Class for compressing files using zlib
    class GzipCompressor
      # @return [String]
      def extname = '.gz'

      # @param file [Pathname]
      def compress(file)
        compressed = "#{file}#{extname}"

        Zlib::GzipWriter.open(compressed, Zlib::BEST_COMPRESSION) do |gz|
          gz.mtime = file.mtime
          gz.orig_name = file.to_s
          gz.write(File.binread(file))
        end
      end
    end
  end
end
