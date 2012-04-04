require 'rolify/adapters/base'

module Rolify
  module Adapter   
    class ResourceAdapter < ResourceAdapterBase
      def resources_find(roles_table, relation, role_name)
        resources = relation.joins("INNER JOIN \"#{roles_table}\" ON \"#{roles_table}\".\"resource_type\" = '#{relation.to_s}'")
        resources = resources.where("#{roles_table}.name = ? AND #{roles_table}.resource_type = ?", role_name, relation.to_s)
        resources
      end

      def in(relation, roles)
        relation.where("#{role_class.to_s.tableize}.id IN (?) AND ((resource_id = #{relation.table_name}.id) OR (resource_id IS NULL))", roles)
      end
    end
  end
end