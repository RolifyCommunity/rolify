module Rolify
  @@role_cname = "Role"
  @@user_cname = "User"
  @@dynamic_shortcuts = false
  @@orm = "active_record"


  def self.configure
    yield self if block_given?
  end

  def self.role_cname
    @@role_cname.constantize
  end

  def self.role_cname=(role_cname)
    @@role_cname = role_cname.camelize
  end

  def self.user_cname
    @@user_cname.constantize
  end

  def self.user_cname=(user_cname)
    @@user_cname = user_cname.camelize
  end

  def self.dynamic_shortcuts
    @@dynamic_shortcuts || false
  end

  def self.dynamic_shortcuts=(is_dynamic)
    @@dynamic_shortcuts = is_dynamic
  end

  def self.orm
    @@orm
  end

  def self.orm=(orm)
    @@orm = orm
    @@adapter = Rolify::Adapter.const_get(orm.camelize)
  end

  def self.adapter
    @@adapter ||= Rolify::Adapter::ActiveRecord
  end

  def self.use_mongoid
    self.orm = "mongoid"
  end


  module Role
    
    def rolify(options = { :role_cname => 'Role' })
       include InstanceMethods
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
      extend Resource
    end
  end

  module Dynamic
 
    def load_dynamic_methods
      Rolify.role_cname.all.each do |r|
        define_dynamic_method(r.name, r.resource)
      end
    end

    def define_dynamic_method(role_name, resource)
      class_eval do 
        define_method("is_#{role_name}?".to_sym) do
        has_role?("#{role_name}")
        end if !method_defined?("is_#{role_name}?".to_sym)
  
        define_method("is_#{role_name}_of?".to_sym) do |arg|
          has_role?("#{role_name}", arg)
        end if !method_defined?("is_#{role_name}_of?".to_sym) && resource
      end
    end
  end
  
  module Resource
       
    def with_role(role_name, user = nil)
      roles = user ? user.roles : Rolify.role_cname
      roles.where(:resource_type => self.to_s)
    end
  end
  
  module InstanceMethods

    def has_role(role_name, resource = nil)
      role = Rolify.adapter.find_or_create_by(role_name, 
                                              (resource.is_a?(Class) ? resource.to_s : resource.class.name if resource), 
                                              (resource.id if resource && !resource.is_a?(Class)))
                                              
      if !roles.include?(role)
        self.class.define_dynamic_method(role_name, resource) if Rolify.dynamic_shortcuts
        Rolify.adapter.add(self, role)
      end
    end
    alias_method :grant, :has_role
  
    def has_role?(role_name, resource = nil)
      Rolify.adapter.find(self.roles, role_name, resource).size > 0
    end

    def has_all_roles?(*args)
      args.each do |arg|
        if arg.is_a? Hash
          return false if !self.has_role?(arg[:name], arg[:resource])
        elsif arg.is_a? String
          return false if !self.has_role?(arg)
        else
          raise ArgumentError, "Invalid argument type: only hash or string allowed"
        end
      end
      true
    end

    def has_any_role?(*args)
      Rolify.adapter.where(self.roles, args).size > 0
    end
  
    def has_no_role(role_name, resource = nil)
      Rolify.adapter.remove(self.roles, role_name, resource)
    end
    alias_method :revoke, :has_no_role
  
    def roles_name
      self.roles.select(:name).map { |r| r.name }
    end

    def method_missing(method, *args, &block)
      if method.to_s.match(/^is_(\w+)_of[?]$/) || method.to_s.match(/^is_(\w+)[?]$/)
        if Rolify.role_cname.where(:name => $1).count > 0
          resource = args.first
          self.class.define_dynamic_method $1, resource
          return has_role?("#{$1}", resource)
        end
      end unless !Rolify.dynamic_shortcuts
      super
    end
  end
  
end