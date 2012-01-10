module Rolify
  
  module Adapter
    
    class Mongoid < Adapter::Base
      
      def self.find(roles, role_name, resource)
        query = build_query(role_name, resource)
        roles.any_of(*query)
      end
      
      def self.find_or_create_by(role_name, resource_type = nil, resource_id = nil)
        Rolify.role_cname.find_or_create_by(:name => role_name, 
                                            :resource_type => resource_type, 
                                            :resource_id => resource_id)
      end
      
      def self.delete(relation, role_name, resource = nil)
        role = { :name => role_name }
        role.merge!({:resource_type => (resource.is_a?(Class) ? resource.to_s : resource.class.name)}) if resource
        role.merge!({ :resource_id => resource.id }) if resource && !resource.is_a?(Class)
        relation.destroy_all(role)
      end
      
      def self.build_conditions(relation, args, count = false)
        conditions = []
        count_conditions = [] if count
        args.each do |arg|
          if arg.is_a? Hash
            query = build_query(arg[:name], arg[:resource])
          elsif arg.is_a? String
            query = build_query(arg)
          else
            raise ArgumentError, "Invalid argument type: only hash or string allowed"
          end
          conditions += query
          #count_conditions << relation.where(a, *v).select("COUNT(id)").to_sql + " > 0" if count
        end
        #count ? [ conditions, count_conditions.join(') AND (') ] : [ conditions, *values ]
        relation.any_of(*conditions)
      end
      
      def self.build_query(role, resource = nil)
        return [{ :name => role }] if resource == :any
        query = [{ :name => role, :resource_type => nil, :resource_id => nil }]
        if resource
          query << { :name => role, :resource_type => (resource.is_a?(Class) ? resource.to_s : resource.class.name), :resource_id => nil }
          if !resource.is_a? Class
            query << { :name => role, :resource_type => resource.class.name, :resource_id => resource.id }
          end
        end
        query
      end
    end
  end
end