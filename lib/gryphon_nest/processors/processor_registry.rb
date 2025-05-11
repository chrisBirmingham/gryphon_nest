# frozen_string_literal: true

module GryphonNest
  module Processors
    class ProcessorRegistry
      def initialize
        @asset_processor = AssetProcessor.new
        @processors = Hash.new(@asset_processor)
      end

      def build
        @processors[TEMPLATE_EXT] = proc {
          renderer = Renderers::MustacheRenderer.new
          renderer.template_path = CONTENT_DIR
          Processors::MustacheProcessor.new(renderer)
        }

        sass_proc = proc {
          @sass_processor = Processors::SassProcessor.new
        }

        @processors['scss'] = sass_proc
        @processors['sass'] = sass_proc
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
