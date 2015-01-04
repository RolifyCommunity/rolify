require 'rubygems'
require "bundler/setup"

require 'rolify'
require 'rolify/matchers'
require 'rails'
require_relative 'support/stream_helpers'
include StreamHelpers

require 'coveralls'
Coveralls.wear_merged!

ENV['ADAPTER'] ||= 'active_record'

if ENV['ADAPTER'] == 'active_record'
  require 'active_record/railtie'
else
  require 'mongoid'
end

module TestApp
  class Application < ::Rails::Application
    config.root = File.dirname(__FILE__)
  end
end

require 'ammeter/init'
