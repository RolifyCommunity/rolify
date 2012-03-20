module Rolify
  
  module Adapter
    
    class Base
      def self.find(relation, role_name, resource)
        raise NotImplementedError.new("You must implement find")
      end
      
      def self.where(relation, args)
        raise NotImplementedError.new("You must implement where")
      end
      
      def self.find_or_create_by(role_name, resource_type = nil, resource_id = nil)
        raise NotImplementedError.new("You must implement find_or_create_by")
      end
      
      def self.add(relation, role_name, resource = nil)
        raise NotImplementedError.new("You must implement add")
      end
      
      def self.remove(relation, role_name, resource = nil)
        raise NotImplementedError.new("You must implement delete")
      end
      
      def self.resources_find(roles_table, relation, role_name)
       raise NotImplementedError.new("You must implement resources_find")
      end
      
      def self.in(resources, roles)
        raise NotImplementedError.new("You must implement in")
      end
      
      def self.exists?(relation, column)
        raise NotImplementedError.new("You must implement exists?")
      end
      
      def self.build_conditions(relation, args)
        raise NotImplementedError.new("You must implement build_conditions")
      end
      
      def self.build_query(role, resource = nil)
        raise NotImplementedError.new("You must implement build_query")
      end
    end
  end
end