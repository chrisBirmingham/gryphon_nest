# frozen_string_literal: true

module GryphonNest
  module Processors
    autoload :AssetProcessor, 'gryphon_nest/processors/asset_processor'
    autoload :MustacheProcessor, 'gryphon_nest/processors/mustache_processor'
    autoload :ProcessorRegistry, 'gryphon_nest/processors/processor_registry'
    autoload :SassProcessor, 'gryphon_nest/processors/sass_processor.rb'
  end
end
