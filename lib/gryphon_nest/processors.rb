# frozen_string_literal: true

module GryphonNest
  module Processors
    autoload :AssetProcessor, 'gryphon_nest/processors/asset_processor'
    autoload :MustacheProcessor, 'gryphon_nest/processors/mustache_processor'
    autoload :SassProcessor, 'gryphon_nest/processors/sass_processor.rb'

    class << self
      # @return [Hash]
      def create
        renderer = Renderers::MustacheRenderer.new
        renderer.template_path = CONTENT_DIR
        asset_processor = Processors::AssetProcessor.new

        processors = Hash.new(asset_processor)
        processors[TEMPLATE_EXT] = Processors::MustacheProcessor.new(renderer)

        begin
          require 'sass-embedded'
          sass = Processors::SassProcessor.new
          processors['.scss'] = sass
          processors['.sass'] = sass
        rescue LoadError; end

        processors
      end
    end
  end
end
