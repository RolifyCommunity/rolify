module Rolify
  module Role
    def has_role(role_name, resource = nil)
      role = Rolify.adapter.find_or_create_by(role_name, 
      (resource.is_a?(Class) ? resource.to_s : resource.class.name if resource), 
      (resource.id if resource && !resource.is_a?(Class)))

      if !roles.include?(role)
        self.class.define_dynamic_method(role_name, resource) if Rolify.dynamic_shortcuts
        Rolify.adapter.add(self, role)
      end
      role
    end
    alias_method :grant, :has_role

    def has_role?(role_name, resource = nil)
      Rolify.adapter.find(self.roles, role_name, resource).size > 0
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

    def respond_to?(method, include_private = false)
      if Rolify.dynamic_shortcuts && (method.to_s.match(/^is_(\w+)_of[?]$/) || method.to_s.match(/^is_(\w+)[?]$/))
        query = Rolify.role_cname.where(:name => $1)
        query = Rolify.adapter.exists?(query, :resource_type) if method.to_s.match(/^is_(\w+)_of[?]$/)
        return true if query.count > 0
        false
      else
        super
      end
    end
  end
end