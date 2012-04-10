require 'rolify/adapters/base'

module Rolify
  module Adapter   
    class RoleAdapter < RoleAdapterBase
      def where(relation, *args)
        conditions, values = build_conditions(relation, args)
        relation.where(conditions, *values)
      end

      def find_or_create_by(role_name, resource_type = nil, resource_id = nil)
        role_class.find_or_create_by_name_and_resource_type_and_resource_id(role_name, resource_type, resource_id)
      end

      def add(relation, role)
        relation.role_ids |= [role.id]
      end

      def remove(relation, role_name, resource = nil)
        roles = relation.roles.where(:name => role_name)
        roles = roles.where(:resource_type => (resource.is_a?(Class) ? resource.to_s : resource.class.name)) if resource
        roles = roles.where(:resource_id => resource.id) if resource && !resource.is_a?(Class)
        if roles
          relation.roles.delete(roles)
          roles.each do |role| 
            role.destroy if role.send(user_class.table_name.to_sym).empty? 
          end
        end
        roles
      end

      def exists?(relation, column)
        relation.where("#{column} IS NOT NULL")
      end
      
      def scope(relation, conditions)
        query = relation.scoped
        query = query.joins(:roles)
        query = where(query, conditions)
        query
      end

      private

      def build_conditions(relation, args)
        conditions = []
        values = []
        args.each do |arg|
          if arg.is_a? Hash
            a, v = build_query(arg[:name], arg[:resource])
          elsif arg.is_a?(String) || arg.is_a?(Symbol)
            a, v = build_query(arg.to_s)
          else
            raise ArgumentError, "Invalid argument type: only hash or string or a symbol allowed"
          end
          conditions << a
          values += v
        end
        conditions = conditions.join(' OR ')
        [ conditions, values ]
      end

      def build_query(role, resource = nil)
        return [ "#{role_table}.name = ?", [ role ] ] if resource == :any
        query = "((#{role_table}.name = ?) AND (#{role_table}.resource_type IS NULL) AND (#{role_table}.resource_id IS NULL))"
        values = [ role ]
        if resource
          query.insert(0, "(")
          query += " OR ((#{role_table}.name = ?) AND (#{role_table}.resource_type = ?) AND (#{role_table}.resource_id IS NULL))" 
          values << role << (resource.is_a?(Class) ? resource.to_s : resource.class.name)
          if !resource.is_a? Class
            query += " OR ((#{role_table}.name = ?) AND (#{role_table}.resource_type = ?) AND (#{role_table}.resource_id = ?))" 
            values << role << resource.class.name << resource.id
          end
          query += ")"
        end
        [ query, values ]
      end
    end
  end
end