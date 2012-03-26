module Rolify
  module Resource
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods 
      def find_roles(role_name = nil, user = nil)
        roles = user && (user != :any) ? user.roles : Rolify.role_cname
        roles = roles.where(:resource_type => self.to_s)
        roles = roles.where(:name => role_name) if role_name && (role_name != :any)
        roles
      end

      def with_role(role_name, user = nil)
        resources = Rolify.adapter.resources_find(Rolify.role_cname.to_s.tableize, self, role_name)
        user ? Rolify.adapter.in(resources, user.roles.where(:name => role_name)) : resources
      end
    end
    
    def applied_roles
      self.roles + Rolify.role_cname.where(:resource_type => self.class.to_s, :resource_id => nil)
    end
  end
end