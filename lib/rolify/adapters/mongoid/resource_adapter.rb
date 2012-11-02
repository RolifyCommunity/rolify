require 'rolify/adapters/base'

module Rolify
  module Adapter
    class ResourceAdapter < ResourceAdapterBase
      def resources_find(roles_table, relation, role_name)
        roles = roles_table.classify.constantize.where(:name.in => Array(role_name), :resource_type => relation.to_s)
        resources = []
        roles.each do |role|
          if role.resource_id.nil?
            resources += relation.all
          else
            resources << role.resource
          end
        end
        resources.compact.uniq
      end

      def in(resources, user, role_names)
        roles = user.roles.where(:name.in => Array(role_names))
        return [] if resources.empty? || roles.empty?
        resources.delete_if { |resource| (resource.applied_roles & roles).empty? }
        resources
      end
    end
  end
end