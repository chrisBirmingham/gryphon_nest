# frozen_string_literal: true

module Gryphon
  module Processors
    autoload :AssetProcessor, 'gryphon/processors/asset_processor'
    autoload :MustacheProcessor, 'gryphon/processors/mustache_processor'
    autoload :SassProcessor, 'gryphon/processors/sass_processor.rb'

    class << self
      # @return [Array]
      def create
        asset_processor = AssetProcessor.new
        processors = Hash.new(@asset_processor)

        layout_file = LayoutFile.new(Pathname(LAYOUT_FILE))
        renderer = Renderers::MustacheRenderer.new
        renderer.template_path = CONTENT_DIR
        processors[TEMPLATE_EXT] = Processors::MustacheProcessor.new(renderer, layout_file)

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
