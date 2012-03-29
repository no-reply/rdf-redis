# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rdf/redis'

Gem::Specification.new do |s|
  s.name        = 'redis-store'
  s.version     = RDF::Redis::VERSION
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
  s.add_dependency 'rdf',         '~> 0.3.4'
  s.add_dependency 'redis',       '~> 2.2.0'

  s.add_development_dependency 'bundler',    '~> 1.1'
  s.add_development_dependency 'rspec',    '~> 2.9.0'
  s.add_development_dependency 'rdf-spec', '~> 0.3.4'
end

