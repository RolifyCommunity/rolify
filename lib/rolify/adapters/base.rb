module Rolify
  module Adapter
    class Base
      def initialize(role_cname)
        @role_cname = role_cname
      end
      
      def role_class
        @role_cname.constantize
      end
      
      def find(relation, role_name, resource)
        raise NotImplementedError.new("You must implement find")
      end
      
      def where(relation, args)
        raise NotImplementedError.new("You must implement where")
      end
      
      def find_or_create_by(role_name, resource_type = nil, resource_id = nil)
        raise NotImplementedError.new("You must implement find_or_create_by")
      end
      
      def add(relation, role_name, resource = nil)
        raise NotImplementedError.new("You must implement add")
      end
      
      def remove(relation, role_name, resource = nil)
        raise NotImplementedError.new("You must implement delete")
      end
      
      def resources_find(roles_table, relation, role_name)
       raise NotImplementedError.new("You must implement resources_find")
      end
      
      def in(resources, roles)
        raise NotImplementedError.new("You must implement in")
      end
      
      def exists?(relation, column)
        raise NotImplementedError.new("You must implement exists?")
      end
      
      def build_conditions(relation, args)
        raise NotImplementedError.new("You must implement build_conditions")
      end
      
      def build_query(role, resource = nil)
        raise NotImplementedError.new("You must implement build_query")
      end
    end
  end
end