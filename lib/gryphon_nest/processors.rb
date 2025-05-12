# frozen_string_literal: true

module GryphonNest
  module Processors
    autoload :AssetProcessor, 'gryphon_nest/processors/asset_processor'
    autoload :MustacheProcessor, 'gryphon_nest/processors/mustache_processor'
    autoload :ProcessorRegistry, 'gryphon_nest/processors/processor_registry'
    autoload :SassProcessor, 'gryphon_nest/processors/sass_processor.rb'

    class << self
      # @return [ProcessorRegistry]
      def create
        ProcessorRegistry.new do |reg|
          reg[TEMPLATE_EXT] = proc {
            renderer = Renderers::MustacheRenderer.new
            renderer.template_path = CONTENT_DIR
            Processors::MustacheProcessor.new(renderer)
          }

          sass_proc = proc { Processors::SassProcessor.new }

          reg['.scss'] = sass_proc
          reg['.sass'] = sass_proc
        end
      end
    end
  end
end
