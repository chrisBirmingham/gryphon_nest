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
  spec.homepage = 'https://github.com/chrisBirmingham/gryphon_nest'
  spec.required_ruby_version = '>= 2.6.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  spec.files = Dir['lib/**/*', 'LICENSE']
  spec.executables << 'nest'
  spec.require_paths = ['lib']
  spec.license = 'Unlicense'

  spec.add_dependency 'htmlbeautifier', '~> 1.0'
  spec.add_dependency 'mustache', '~> 1.0'
  spec.add_dependency 'webrick', '~> 1.0'

  spec.add_development_dependency 'bundler', '~> 2.3'
  spec.add_development_dependency 'rake', '~> 13.0'
end
