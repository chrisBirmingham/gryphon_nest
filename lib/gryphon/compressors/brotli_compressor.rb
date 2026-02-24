#frozen_string_literal: true

module Gryphon
  module Compressors
    class BrotliCompressor
      def extname
        '.br'
      end

      # @param file [Pathname]
      def compress(file)
        compressed = "#{file}#{extname}"

        File.open(compressed, 'wb') do |br|
          writer = Brotli::Writer.new(br)
          writer.write(IO.binread(file))
          writer.close
        end
      end
    end
  end
end
