require 'active_record'

require 'rolify/adapters/base'
require 'rolify/adapters/active_record' if defined?(ActiveRecord)
require 'rolify/adapters/mongoid' if defined?(Mongoid)
require 'rolify/railtie' if defined?(Rails)
require 'rolify/role'