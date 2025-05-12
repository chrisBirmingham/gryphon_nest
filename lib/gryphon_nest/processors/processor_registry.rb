# frozen_string_literal: true

module GryphonNest
  module Processors
    class ProcessorRegistry
      def initialize
        @asset_processor = AssetProcessor.new
        @processors = Hash.new(@asset_processor)
        yield self
      end

      # @param key [String]
      # @param value [Proc]
      def []=(key, value)
        @processors[key] = value
      end

      # @param key [String]
      # @return [Object]
      def [](key)
        processor = @processors[key]

        if processor.is_a?(Proc)
          processor = processor.call
          @processors[key] = processor
        end

        processor
      rescue LoadError
        @processors[key] = nil
        @asset_processor
      end
    end
  end
end
