require 'rolify/adapters/base'

module Rolify
  module Adapter  
    class ResourceAdapter < ResourceAdapterBase
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
        resources.delete_if { |resource| (resource.applied_roles & roles).empty? }
        resources
      end
    end
  end
end