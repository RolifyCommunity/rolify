require 'rolify/adapters/base'

module Rolify
  module Adapter
    class ResourceAdapter < ResourceAdapterBase
      def resources_find(roles_table, relation, role_name)
        resources = relation.joins("INNER JOIN #{quote(roles_table)} ON #{quote(roles_table)}.resource_type = '#{resource_type(relation)}' AND
                                    (#{quote(roles_table)}.resource_id IS NULL OR #{quote(roles_table)}.resource_id = #{quote(relation.table_name)}.#{relation.primary_key})")
        resources = resources.where("#{quote(roles_table)}.name IN (?) AND #{quote(roles_table)}.resource_type = ?", Array(role_name), resource_type(relation))
        resources = resources.select("#{quote(relation.table_name)}.*")
        resources
      end

      def in(relation, user, role_names)
        roles = user.roles.where(:name => role_names)
        relation.where("#{quote(role_class.table_name)}.#{role_class.primary_key} IN (?) AND ((resource_id = #{quote(relation.table_name)}.#{relation.primary_key}) OR (resource_id IS NULL))", roles)
      end

      private

      def quote(column)
         ActiveRecord::Base.connection.quote_column_name column
      end

      # Returns the string value for the relation's resource_type,
      # If relation is an STI subclass, the base class value is used.
      def resource_type(relation)
        (relation.respond_to?(:base_class) ? relation.base_class : relation).to_s
      end
    end
  end
end
