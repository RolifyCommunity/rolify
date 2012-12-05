require 'rolify/railtie' if defined?(Rails)
require 'rolify/utils'
require 'rolify/role'
require 'rolify/configure'
require 'rolify/dynamic'
require 'rolify/resource'
require 'rolify/adapters/base'

module Rolify
  extend Configure

  attr_accessor :role_cname, :adapter, :role_table_name

  def rolify(options = {})
    include Role
    extend Dynamic if Rolify.dynamic_shortcuts
    
    options.reverse_merge!({:role_cname => 'Role'})
    self.role_cname = options[:role_cname]
    self.role_table_name = self.role_cname.tableize.gsub(/\//, "_")

    join_table = "#{self.to_s.tableize.gsub(/\//, "_")}_#{self.role_table_name}"
    rolify_options = { :class_name => options[:role_cname].camelize }
    rolify_options.merge!({ :join_table => join_table }) if Rolify.orm == "active_record"
    rolify_options.merge!(options.reject{ |k,v| ![:before_add, :after_add, :before_remove, :after_remove].include? k.to_sym }) if Rolify.orm == "active_record"

    has_and_belongs_to_many :roles, rolify_options

    self.adapter = Rolify::Adapter::Base.create("role_adapter", self.role_cname, self.name)
    load_dynamic_methods if Rolify.dynamic_shortcuts
  end

  def resourcify(options = {})
    include Resource
    
    options.reverse_merge!({ :role_cname => 'Role', :dependent => :destroy })
    resourcify_options = { :class_name => options[:role_cname].camelize, :as => :resource, :dependent => options[:dependent] }
    self.role_cname = options[:role_cname]
    self.role_table_name = self.role_cname.tableize.gsub(/\//, "_")

    has_many :roles, resourcify_options
    
    self.adapter = Rolify::Adapter::Base.create("resource_adapter", self.role_cname, self.name)
  end
  
  def scopify
    require "rolify/adapters/#{Rolify.orm}/scopes.rb"
    extend Rolify::Adapter::Scopes 
  end
  
  def role_class
    self.role_cname.constantize
  end
end
