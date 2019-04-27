require 'rolify/adapters/base'
require 'rolify/configure'
require 'rolify/dynamic'
require 'rolify/railtie' if defined? Rails
require 'rolify/resource'
require 'rolify/role'

module Rolify
  extend Configure

  ROLIFY_ASSOCIATION_OPTIONS = %i[
    before_add
    after_add
    before_remove
    after_remove
    inverse_of
  ].freeze

  attr_writer :resource_adapter, :adapter

  attr_accessor :role_cname, :role_join_table_name, :role_table_name,
                :strict_rolify

  @@resource_types = []

  def rolify(options = {})
    include Role
    extend Dynamic if Rolify.dynamic_shortcuts

    options.reverse_merge! role_cname: 'Role'
    self.role_cname = options[:role_cname]
    self.role_table_name = role_cname.tableize.tr('/', '_')

    default_join_table = "#{to_s.tableize.tr('/', '_')}_#{role_table_name}"
    options.reverse_merge! role_join_table_name: default_join_table
    self.role_join_table_name = options[:role_join_table_name]

    rolify_options = { class_name: options[:role_cname].camelize }
    rolify_options[:join_table] = role_join_table_name if Rolify.orm == 'active_record'
    rolify_options.merge! options.select { |k, _| ROLIFY_ASSOCIATION_OPTIONS.include? k.to_sym }

    has_and_belongs_to_many :roles, rolify_options

    self.adapter = Rolify::Adapter::Base.create('role_adapter', role_cname, name)

    #use strict roles
    self.strict_rolify = true if options[:strict]
  end

  def adapter
    return superclass.adapter unless instance_variable_defined? '@adapter'

    @adapter
  end

  def resourcify(association_name = :roles, options = {})
    include Resource

    options.reverse_merge! role_cname: 'Role', dependent: :destroy
    resourcify_options = { class_name: options[:role_cname].camelize, as: :resource, dependent: options[:dependent] }
    self.role_cname = options[:role_cname]
    self.role_table_name = role_cname.tableize.tr('/', '_')

    has_many association_name, resourcify_options

    self.resource_adapter = Rolify::Adapter::Base.create('resource_adapter', role_cname, name)
    @@resource_types << self.name
  end

  def resource_adapter
    return superclass.resource_adapter unless instance_variable_defined? '@resource_adapter'

    @resource_adapter
  end

  def scopify
    require "rolify/adapters/#{Rolify.orm}/scopes.rb"
    extend Rolify::Adapter::Scopes
  end

  def role_class
    return superclass.role_class unless instance_variable_defined? '@role_cname'

    role_cname.constantize
  end

  def self.resource_types
    @@resource_types
  end
end
