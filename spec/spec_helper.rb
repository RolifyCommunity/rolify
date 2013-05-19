require 'rubygems'
require "bundler/setup"

require 'rolify'
require 'rolify/matchers'
require 'rails/all'

require 'coveralls'
Coveralls.wear!

ENV['ADAPTER'] ||= 'active_record'

load File.dirname(__FILE__) + "/support/adapters/#{ENV['ADAPTER']}.rb"
load File.dirname(__FILE__) + '/support/data.rb'

def reset_defaults
  Rolify.use_defaults
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
