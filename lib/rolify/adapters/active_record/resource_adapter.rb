require 'rolify/adapters/base'

module Rolify
  module Adapter   
    class ResourceAdapter < ResourceAdapterBase
      def resources_find(roles_table, relation, role_name)
        resources = relation.joins("INNER JOIN #{quote(roles_table)} ON #{quote(roles_table)}.resource_type = '#{relation.to_s}' AND 
                                    (#{quote(roles_table)}.resource_id IS NULL OR #{quote(roles_table)}.resource_id = #{quote(relation.table_name)}.id)")
        resources = resources.where("#{quote(roles_table)}.name IN (?) AND #{quote(roles_table)}.resource_type = ?", Array(role_name), relation.to_s)
        resources
      end

      def in(relation, user, role_names)
        roles = user.roles.where(:name => role_names)
        relation.where("#{quote(role_class.to_s.tableize)}.id IN (?) AND ((resource_id = #{quote(relation.table_name)}.id) OR (resource_id IS NULL))", roles)
      end
      
      private
      
      def quote(column)
         ActiveRecord::Base.connection.quote_column_name column
      end
    end
  end
end