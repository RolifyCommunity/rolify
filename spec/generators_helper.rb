require 'rubygems'
require "bundler/setup"

require 'rolify'
require 'rolify/matchers'
require 'rails/all'

require 'coveralls'
Coveralls.wear!

module TestApp
  class Application < ::Rails::Application
    config.root = File.dirname(__FILE__)
  end
end

require 'ammeter/init'

ENV['ADAPTER'] ||= 'active_record'


