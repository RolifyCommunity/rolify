module Rolify
  module Resource
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods 
      def find_roles(role_name = nil, user = nil)
        roles = user && (user != :any) ? user.roles : self.role_class
        roles = roles.where(:resource_type => self.to_s)
        roles = roles.where(:name => role_name.to_s) if role_name && (role_name != :any)
        roles
      end

      def with_role(role_name, user = nil)
        if role_name.is_a? Array
          role_name.map!(&:to_s)
        else
          role_name = role_name.to_s
        end
        klass = class_with_adapter
        resources = klass.adapter.resources_find(klass.role_table_name, self, role_name)
        user ? klass.adapter.in(resources, user, role_name) : resources
      end
      alias :with_roles :with_role

      private
      def class_with_adapter(klass = self)
        while ( !klass.adapter )
          klass = klass.superclass
        end
        klass
      end
    end

    def roles_for_class
      # this is a corrected roles relation ( to deal with polymorphism inheritance )
      self.roles.unscoped.where(resource_id: self.id, resource_type: self.class.name)
    end
    
    def applied_roles
      klass = class_with_adapter(self.class)
      self.roles_for_class + klass.role_class.where(:resource_type => self.class.to_s, :resource_id => nil)
    end

    private
    def class_with_adapter(klass = self)
      while ( !klass.adapter )
        klass = klass.superclass
      end
      klass
    end
  end
end
