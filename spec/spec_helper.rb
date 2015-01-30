require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'rubygems'
require "bundler/setup"

require 'rolify'
require 'rolify/matchers'
require 'rails'
begin
  require 'its'
rescue LoadError
end
require 'coveralls'
Coveralls.wear_merged!

ENV['ADAPTER'] ||= 'active_record'

load File.dirname(__FILE__) + "/support/adapters/#{ENV['ADAPTER']}.rb"
load File.dirname(__FILE__) + '/support/data.rb'

begin
  require 'pry'
rescue LoadError
end

def reset_defaults
  Rolify.use_defaults
  Rolify.use_mongoid if ENV['ADAPTER'] == 'mongoid'
end

def provision_user(user, roles)
  roles.each do |role|
    if role.is_a? Array
      user.add_role *role
    else
      user.add_role role
    end
  end
  user
end

def silence_warnings(&block)
  warn_level = $VERBOSE
  $VERBOSE = nil
  result = block.call
  $VERBOSE = warn_level
  result
end
