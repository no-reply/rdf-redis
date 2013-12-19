# -*- encoding: utf-8 -*-
# lib = File.expand_path('../lib', __FILE__)
# $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
# require 'rdf/redis'

Gem::Specification.new do |s|
  s.name        = 'redis-store'
  s.version     = '0.0.2'
  s.authors     = ['Luca Guidi']
  s.email       = ['me@lucaguidi.com']
  s.homepage    = ''
  s.summary     = %q{Redis backend for RDF}
  s.description = %q{Redis backend for RDF}

  s.rubyforge_project = 'rdf-redis'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'addressable', '>= 2.2.6'
  s.add_dependency 'rdf'
  s.add_dependency 'redis'

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rdf-spec'
end
