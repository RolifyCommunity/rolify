require "rolify/finders"

module Rolify
  module Role
    extend Utils
    
    def self.included(base)
      base.extend Finders
    end
          
    def add_role(role_name, resource = nil)
      role = self.class.adapter.find_or_create_by(role_name.to_s, 
                                                  (resource.is_a?(Class) ? resource.to_s : resource.class.name if resource), 
                                                  (resource.id if resource && !resource.is_a?(Class)))

      if !roles.include?(role)
        self.class.define_dynamic_method(role_name, resource) if Rolify.dynamic_shortcuts
        self.class.adapter.add(self, role)
      end
      role
    end
    alias_method :grant, :add_role
    deprecate :has_role, :add_role

    def has_role?(role_name, resource = nil)
      if new_record?
        self.roles.detect { |r| r.name == role_name.to_s && (r.resource == resource || resource.nil?) }.present?
      else
        self.class.adapter.where(self.roles, :name => role_name, :resource => resource).size > 0
      end
    end

    def has_all_roles?(*args)
      args.each do |arg|
        if arg.is_a? Hash
          return false if !self.has_role?(arg[:name], arg[:resource])
        elsif arg.is_a?(String) || arg.is_a?(Symbol)
          return false if !self.has_role?(arg)
        else
          raise ArgumentError, "Invalid argument type: only hash or string or symbol allowed"
        end
      end
      true
    end

    def has_any_role?(*args)
      self.class.adapter.where(self.roles, *args).size > 0
    end
    
    def only_has_role?(role_name, resource = nil)
      return self.has_role?(role_name,resource) && self.roles.count == 1
    end

    def remove_role(role_name, resource = nil)
      self.class.adapter.remove(self, role_name, resource)
    end
    
    alias_method :revoke, :remove_role
    deprecate :has_no_role, :remove_role

    def roles_name
      self.roles.select(:name).map { |r| r.name }
    end

    def method_missing(method, *args, &block)
      if method.to_s.match(/^is_(\w+)_of[?]$/) || method.to_s.match(/^is_(\w+)[?]$/)
        if self.class.role_class.where(:name => $1).count > 0
          resource = args.first
          self.class.define_dynamic_method $1, resource
          return has_role?("#{$1}", resource)
        end
      end unless !Rolify.dynamic_shortcuts
      super
    end

    def respond_to?(method, include_private = false)
      if Rolify.dynamic_shortcuts && (method.to_s.match(/^is_(\w+)_of[?]$/) || method.to_s.match(/^is_(\w+)[?]$/))
        query = self.class.role_class.where(:name => $1)
        query = self.class.adapter.exists?(query, :resource_type) if method.to_s.match(/^is_(\w+)_of[?]$/)
        return true if query.count > 0
        false
      else
        super
      end
    end
  end
end