module Rolify
  
  module Adapter
    
    class ActiveRecord < Adapter::Base
      
      def self.find(relation, role_name, resource)
        query, values = Rolify.adapter.build_query(role_name, resource)
        relation.where(query, *values)
      end
      
      def self.where(relation, args)
        conditions, values = build_conditions(relation, args)
        relation.where(conditions, *values)
      end
      
      def self.find_or_create_by(role_name, resource_type = nil, resource_id = nil)
        Rolify.role_cname.find_or_create_by_name_and_resource_type_and_resource_id( :name => role_name, 
                                                                                    :resource_type => resource_type, 
                                                                                    :resource_id => resource_id)
      end
      
      def self.add(relation, role)
        relation.role_ids |= [role.id]
      end
      
      def self.delete(relation, role_name, resource = nil)
        role = relation.where(:name => role_name)
        role = role.where(:resource_type => (resource.is_a?(Class) ? resource.to_s : resource.class.name)) if resource
        role = role.where(:resource_id => resource.id) if resource && !resource.is_a?(Class)
        relation.delete(role) if role
      end
      
      def self.build_conditions(relation, args)
        conditions = []
        values = []
        args.each do |arg|
          if arg.is_a? Hash
            a, v = build_query(arg[:name], arg[:resource])
          elsif arg.is_a? String
            a, v = build_query(arg)
          else
            raise ArgumentError, "Invalid argument type: only hash or string allowed"
          end
          conditions << a
          values += v
        end
        conditions = conditions.join(' OR ')
        [ conditions, values ]
      end
      
      def self.build_query(role, resource = nil)
        return [ "name = ?", [ role ] ] if resource == :any
        query = "((name = ?) AND (resource_type IS NULL) AND (resource_id IS NULL))"
        values = [ role ]
        if resource
          query.insert(0, "(")
          query += " OR ((name = ?) AND (resource_type = ?) AND (resource_id IS NULL))" 
          values << role << (resource.is_a?(Class) ? resource.to_s : resource.class.name)
          if !resource.is_a? Class
            query += " OR ((name = ?) AND (resource_type = ?) AND (resource_id = ?))" 
            values << role << resource.class.name << resource.id
          end
          query += ")"
        end
        [ query, values ]
      end
    end
  end
end