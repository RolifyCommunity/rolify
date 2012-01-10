module Rolify
  
  module Adapter
    
    class ActiveRecord < Adapter::Base
      
      def self.find(query, values)
        where(query, *values)
      end
      
      def self.find_or_create_by(role_name, resource_type = nil, resource_id = nil)
        Rolify.role_cname.find_or_create_by_name_and_resource_type_and_resource_id( :name => role_name, 
                                                                                    :resource_type => resource_type, 
                                                                                    :resource_id => resource_id)
      end
      
      def self.build_conditions(relation, args, count = false)
        conditions = []
        count_conditions = [] if count
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
          count_conditions << relation.where(a, *v).select("COUNT(id)").to_sql + " > 0" if count
          values += v
        end
        count ? [ conditions, values, count_conditions ] : [ conditions, values ]
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