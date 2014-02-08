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

    options.reverse_merge!({ :role_cname => 'Role', :dependent => :destroy })
    self.role_cname = options[:role_cname]
    self.role_table_name = self.role_cname.tableize.gsub(/\//, "_")

    rolify_options = { :class_name => options[:role_cname].camelize, :dependent => options[:dependent] }
    rolify_options.merge!(options.reject{ |k,v| ![ :before_add, :after_add, :before_remove, :after_remove ].include? k.to_sym })

    has_many :roles, rolify_options
    has_many :groups, :through => :roles, :source => :resource, :source_type => 'Group'

    self.adapter = Rolify::Adapter::Base.create("role_adapter", self.role_cname, self.name)
    load_dynamic_methods if Rolify.dynamic_shortcuts
  end

  def resourcify(role_association_name = :roles, target_association_name = :users, options = {})
    include Resource

    options.reverse_merge!({ :role_cname => 'Role', :dependent => :destroy, :as => :resource })
    resourcify_options = { :class_name => options[:role_cname].camelize, :dependent => options[:dependent], :as => options[:as] }
    self.role_cname = options[:role_cname]
    self.role_table_name = self.role_cname.tableize.gsub(/\//, "_")

    has_many role_association_name, resourcify_options
    has_many target_association_name, :through => role_association_name, :as => :resource

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
