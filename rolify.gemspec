# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rolify/version"

Gem::Specification.new do |s|
  s.name        = "rolify"
  s.version     = Rolify::VERSION
  s.platform    = Gem::Platform::RUBY
  s.license     = "MIT"
  s.authors     = ["Florent Monbillard"]
  s.email       = ["f.monbillard@gmail.com"]
  s.homepage    = "http://eppo.github.com/rolify/"
  s.summary     = %q{Roles library with resource scoping}
  s.description = %q{Very simple Roles library without any authorization enforcement supporting scope on resource objects (instance or class). Supports ActiveRecord and Mongoid ORMs.}

  s.rubyforge_project = s.name

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency "ammeter"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", ">= 2.0"
  s.add_development_dependency "rspec-rails", ">= 2.0"
  s.add_development_dependency "bundler"
  s.add_development_dependency "fuubar" 
end
