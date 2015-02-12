# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'rolify/version'

Gem::Specification.new do |s|
  s.name        = 'rolify'
  s.summary     = %q{Roles library with resource scoping}
  s.description = %q{Very simple Roles library without any authorization enforcement supporting scope on resource objects (instance or class). Supports ActiveRecord and Mongoid ORMs.}
  s.version     = Rolify::VERSION
  s.platform    = Gem::Platform::RUBY
  s.homepage    = 'https://github.com/RolifyCommunity/rolify'
  s.rubyforge_project = s.name

  s.license     = 'MIT'

  s.authors     = ['Florent Monbillard']
  s.email       = ['f.monbillard@gmail.com']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'ammeter',     '~> 1.1.2' # Spec generator
  s.add_development_dependency 'bundler',     '>= 1.7.12' # packaging feature
  s.add_development_dependency 'rake',        '~> 10.4.2' # Tasks manager
  s.add_development_dependency 'rspec-rails', '2.99.0'
end
