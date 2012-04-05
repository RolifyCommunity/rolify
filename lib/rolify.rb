require 'rolify/railtie' if defined?(Rails)
require 'rolify/utils'
require 'rolify/role'
require 'rolify/configure'
require 'rolify/dynamic'
require 'rolify/resource'
require 'rolify/adapters/base'

module Rolify
  extend Configure

  attr_accessor :role_cname, :adapter

  def rolify(options = { :role_cname => 'Role' })
    include Role
    extend Dynamic if Rolify.dynamic_shortcuts
    
    rolify_options = { :class_name => options[:role_cname].camelize }
    rolify_options.merge!({ :join_table => "#{self.to_s.tableize}_#{options[:role_cname].tableize}" }) if Rolify.orm == "active_record"
    has_and_belongs_to_many :roles, rolify_options

    self.adapter = Rolify::Adapter::Base.create("role_adapter", options[:role_cname], self.name)
    self.role_cname = options[:role_cname]
    
    load_dynamic_methods if Rolify.dynamic_shortcuts
  end

  def resourcify(options = { :role_cname => 'Role' })
    include Resource
    
    resourcify_options = { :class_name => options[:role_cname].camelize }
    resourcify_options.merge!({ :as => :resource })
    has_many :roles, resourcify_options
    
    self.adapter = Rolify::Adapter::Base.create("resource_adapter", options[:role_cname], self.name)
    self.role_cname = options[:role_cname]
  end
  
  def role_class
    self.role_cname.constantize
  end
end