# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'loggify/version'

Gem::Specification.new do |spec|
  spec.name          = 'loggify'
  spec.version       = Loggify::VERSION
  spec.authors       = ['Joakim Reinert']
  spec.email         = ['reinert@meso.net']

  spec.summary       = 'Unintrusive logging for ruby applications'
  spec.description   =
    'Adds logging to your application without cluttering your code with ' \
    'logger calls'
  spec.homepage      = 'https://github.com/meso-unimpressed/loggify'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{spec/})
  end

  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.4'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.8'
  spec.add_development_dependency 'guard', '~> 2.1'
  spec.add_development_dependency 'guard-rspec', '~> 4.7'
end
