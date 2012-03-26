require 'active_record'

require 'rolify/adapters/base'
require 'rolify/adapters/active_record' if defined?(ActiveRecord)
require 'rolify/adapters/mongoid' if defined?(Mongoid)
require 'rolify/railtie' if defined?(Rails)
require 'rolify/role'
require 'rolify/configure'
require 'rolify/dynamic'
require 'rolify/resource'

module Rolify
  extend Configure

  def rolify(options = { :role_cname => 'Role' })
    include Role
    extend Dynamic if Rolify.dynamic_shortcuts
    rolify_options = { :class_name => options[:role_cname].camelize }
    rolify_options.merge!({ :join_table => "#{self.to_s.tableize}_#{options[:role_cname].tableize}" }) if Rolify.orm == "active_record"
    has_and_belongs_to_many :roles, rolify_options

    load_dynamic_methods if Rolify.dynamic_shortcuts
    Rolify.role_cname = options[:role_cname]
  end

  def resourcify(options = { :role_cname => 'Role' })
    resourcify_options = { :class_name => options[:role_cname].camelize }
    resourcify_options.merge!({ :as => :resource })
    has_many :roles, resourcify_options
    include Resource
  end
end