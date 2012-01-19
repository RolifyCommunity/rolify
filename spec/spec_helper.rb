require 'rubygems'
require 'bundler/setup'

require 'mongoid'
Bundler.require(:default, :development, :test)
require 'rolify'
require 'ammeter/init'

ENV['ADAPTER'] ||= 'active_record'

load File.dirname(__FILE__) + "/support/adapters/#{ENV['ADAPTER']}.rb"
load File.dirname(__FILE__) + '/support/data.rb'