# frozen_string_literal: true

lib = File.expand_path('lib', __dir__).freeze
$LOAD_PATH.unshift lib unless $LOAD_PATH.include? lib

require 'rolify/version'

Gem::Specification.new do |s|
  s.name     = 'rolify'
  s.version  = Rolify::VERSION
  s.license  = 'MIT'
  s.homepage = 'https://github.com/RolifyCommunity/rolify'
  s.summary  = 'Roles library with resource scoping'
  s.platform = Gem::Platform::RUBY

  s.required_ruby_version = '>= 2.3'
  s.rubyforge_project     = s.name

  s.authors = ['Florent Monbillard',     'Wellington Cordeiro']
  s.email   = ['f.monbillard@gmail.com', 'wellington@wellingtoncordeiro.com']

  s.description = <<~DESCRIPTION.split("\n").join(' ')
    Very simple Roles library without any authorization enforcement
    supporting scope on resource objects (instance or class).
    Supports ActiveRecord and Mongoid ORMs.
  DESCRIPTION

  s.metadata = {
    'homepage_uri'    => 'https://github.com/RolifyCommunity/rolify',
    'source_code_uri' => 'https://github.com/RolifyCommunity/rolify',
    'bug_tracker_uri' => 'https://github.com/RolifyCommunity/rolify/issues',
  }.freeze

  s.bindir        = 'exe'
  s.require_paths = ['lib']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = `git ls-files -- exe/*`.split("\n").map { |f| File.basename(f) }

  s.add_development_dependency 'ammeter',     '~> 1.1' # Spec generator
  s.add_development_dependency 'bundler',     '~> 2.0' # packaging feature
  s.add_development_dependency 'rake',        '~> 12.3' # Tasks manager
  s.add_development_dependency 'rspec-rails', '~> 3.8'
  s.add_development_dependency 'rubocop',     '~> 0.67.2'
end
