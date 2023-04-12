# frozen_string_literal: true

require_relative 'lib/gryphon_nest/version'

name = File.basename(__FILE__, '.gemspec')

Gem::Specification.new do |spec|
  spec.name = name
  spec.version = GryphonNest::VERSION
  spec.authors = ['Christopher Birmingham']
  spec.email = ['chris.birmingham@hotmail.co.uk']

  spec.summary = 'Yet another static site generator'
  spec.description = 'A opinionated static website generator for html using mustache'
  #spec.homepage = "TODO: Put your gem's website or public repo URL here."
  spec.required_ruby_version = '>= 2.6.0'

  #spec.metadata["homepage_uri"] = spec.homepage
  #spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."

  spec.files = Dir['lib/**/*']
  spec.executables << 'nest'
  spec.require_paths = ['lib']
  spec.license = 'Unlicense'

  spec.add_dependency 'htmlbeautifier', '~> 1.0'
  spec.add_dependency 'mustache', '~> 1.0'
  spec.add_dependency 'webrick', '~> 1.0'
end
