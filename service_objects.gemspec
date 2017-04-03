# coding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'service_objects/version'

Gem::Specification.new do |spec|
  spec.name          = 'service_objects'
  spec.version       = ServiceObjects::VERSION
  spec.authors       = ['Alexey Kuznetsov']
  spec.email         = ['me@kuznetsoff.io']

  spec.summary       = '' # TODO
  spec.description   = '' # TODO
  spec.homepage      = 'http://github.com/semenovDL/service_objects'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^spec/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = %w(lib)

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
