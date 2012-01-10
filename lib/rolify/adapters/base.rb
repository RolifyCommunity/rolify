module Rolify
  
  module Adapter
    
    class Base
      def self.find(roles, role_name, resource)
        raise NotImplementedError.new("You must implement find")
      end
      
      def self.find_or_create_by(role_name, resource_type = nil, resource_id = nil)
        raise NotImplementedError.new("You must implement find_or_create_by")
      end
      
      def self.delete(relationn, role_name, resource = nil)
        raise NotImplementedError.new("You must implement delete")
      end
      
      def self.build_conditions(relation, args, count = false)
        raise NotImplementedError.new("You must implement build_conditions")
      end
      
      def self.build_query(role, resource = nil)
        raise NotImplementedError.new("You must implement build_query")
      end
    end
  end
end