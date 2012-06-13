module Rolify
  module Resource
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods 
      def find_roles(role_name = nil, user = nil)
        roles = user && (user != :any) ? user.roles : self.role_class
        roles = roles.where(:resource_type => self.to_s)
        roles = roles.where(:name => role_name) if role_name && (role_name != :any)
        roles
      end

      def with_role(role_name, user = nil)
        resources = self.adapter.resources_find(self.role_class.to_s.tableize, self, role_name)
        user ? self.adapter.in(resources, user, role_name) : resources
      end
      alias :with_roles :with_role
    end
    
    def applied_roles
      self.roles + self.class.role_class.where(:resource_type => self.class.to_s, :resource_id => nil)
    end
  end
end