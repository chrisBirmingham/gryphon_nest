# frozen_literal_string: true

require 'zlib'

module GryphonNest
  class GzipCompressor
    # @param file [Pathname]
    # @return [Boolean]
    def can_compress?(file)
      file.size >= 20
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
