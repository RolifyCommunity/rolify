require 'active_record'

require 'rolify/role'
require 'rolify/adapters/base'
require 'rolify/adapters/active_record' if defined?(ActiveRecord)
require 'rolify/adapters/mongoid' if defined?(Mongoid)