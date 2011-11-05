require 'rubygems'
require 'bundler/setup'

Bundler.require(:default, :test)
require 'rolify'
require 'ammeter/init'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Base.logger = Logger.new(File.open('logs/database.log', 'a'))

load File.dirname(__FILE__) + '/support/schema.rb'
load File.dirname(__FILE__) + '/support/models.rb'
load File.dirname(__FILE__) + '/support/data.rb'