require 'rubygems'
require "bundler/setup"

require 'pry'

require 'rolify'
require 'rolify/matchers'
require 'rails/all'
require_relative 'support/stream_helpers'
include StreamHelpers

require 'coveralls'
Coveralls.wear_merged!

require 'common_helper'

ENV['ADAPTER'] ||= 'active_record'

if ENV['ADAPTER'] == 'active_record'
  require 'active_record/railtie'
  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
else
  require 'mongoid'
  Mongoid.load!("spec/support/adapters/mongoid.yml", :test)
end

module TestApp
  class Application < ::Rails::Application
    config.root = File.dirname(__FILE__)
  end
end

require 'ammeter/init'
