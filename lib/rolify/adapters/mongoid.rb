require 'rolify/adapters/base'

module Rolify
  module Adapter  
    class Mongoid < Adapter::Base
      def find(relation, role_name, resource)
        query = build_query(role_name, resource)
        query.each do |condition|
          criteria = relation.where(condition)
          return criteria.all if !criteria.empty?
        end
        []
      end

      def where(relation, args)
        conditions = build_conditions(relation, args)
        relation.any_of(*conditions)
      end

      def find_or_create_by(role_name, resource_type = nil, resource_id = nil)
        self.role_class.find_or_create_by(:name => role_name, 
                                          :resource_type => resource_type, 
                                          :resource_id => resource_id)
      end

      def add(relation, role)
        relation.roles << role
      end

      def remove(relation, role_name, resource = nil)
        role = { :name => role_name }
        role.merge!({:resource_type => (resource.is_a?(Class) ? resource.to_s : resource.class.name)}) if resource
        role.merge!({ :resource_id => resource.id }) if resource && !resource.is_a?(Class)
        relation.where(role).destroy_all
      end

      def resources_find(roles_table, relation, role_name)
        roles = roles_table.classify.constantize.where(:name => role_name, :resource_type => relation.to_s)
        resources = []
        roles.each do |role|
          return relation.all if role.resource_id.nil?
          resources << role.resource
        end
        resources
      end

      def in(resources, roles)
        return [] if resources.empty? || roles.empty?
        resources.delete_if { |resource| (resource.applied_roles && roles).empty? }
        resources
      end

      def exists?(relation, column)
        relation.where(column.to_sym.ne => nil)
      end

      private

      def build_conditions(relation, args)
        conditions = []
        args.each do |arg|
          if arg.is_a? Hash
            query = build_query(arg[:name], arg[:resource])
          elsif arg.is_a?(String) || arg.is_a?(Symbol)
            query = build_query(arg)
          else
            raise ArgumentError, "Invalid argument type: only hash or string or symbol allowed"
          end
          conditions += query
        end
        conditions
      end

      def build_query(role, resource = nil)
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