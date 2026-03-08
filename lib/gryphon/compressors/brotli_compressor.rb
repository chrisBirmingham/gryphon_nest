# frozen_string_literal: true

module Gryphon
  module Compressors
    # Class for compressing files using brotli
    class BrotliCompressor
      # @return [String]
      def extname = '.br'

      # @param file [Pathname]
      def compress(file)
        compressed = "#{file}#{extname}"

        File.open(compressed, 'wb') do |br|
          writer = Brotli::Writer.new(br)
          writer.write(File.binread(file))
          writer.close
        end
      end
    end
  end
end
