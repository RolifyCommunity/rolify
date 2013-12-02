require 'rolify/adapters/base'

module Rolify
  module Adapter
    class RoleAdapter < RoleAdapterBase
      def where(relation, *args)
        conditions, values = build_conditions(relation, args)
        relation.where(conditions, *values)
      end

      def find_or_create_by(role_name, resource_type = nil, resource_id = nil)
        role_class.where(:name => role_name, :resource_type => resource_type, :resource_id => resource_id).first_or_create
      end

      def add(relation, role)
        relation.role_ids |= [role.id]
      end

      def remove(relation, role_name, resource = nil)
        cond = { :name => role_name }
        cond[:resource_type] = (resource.is_a?(Class) ? resource.to_s : resource.class.name) if resource
        cond[:resource_id] = resource.id if resource && !resource.is_a?(Class)
        roles = relation.roles.where(cond)
        if roles
          relation.roles.delete(roles)
          roles.each do |role|
            role.destroy if role.send(ActiveSupport::Inflector.demodulize(user_class).tableize.to_sym).empty?
          end
        end
        roles
      end

      def exists?(relation, column)
        relation.where("#{column} IS NOT NULL")
      end

      def scope(relation, conditions)
        if Rails.version < "4.0"
          query = relation.scoped
        else
          query = relation.all
        end
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
          query += " OR ((#{role_table}.name = ?) AND (#{role_table}.resource_type IN (?)) AND (#{role_table}.resource_id IS NULL))"
          values << role << class_resource_type(resource)
          if !resource.is_a? Class
            query += " OR ((#{role_table}.name = ?) AND (#{role_table}.resource_type = ?) AND (#{role_table}.resource_id = ?))"
            values << role << instance_resource_type(resource) << resource.id
          end
          query += ")"
        end
        [ query, values ]
      end

      # Return string of class name for the given resource instance,
      # taking care to chose the correct name when STI is involved.
      def instance_resource_type(resource)
        resource or return
        (resource.class.respond_to?(:base_class) ? resource.class.base_class : resource.class).name
      end

      # Return a list of string class names for the given class. The
      # given type and any STI parent types are included in the list.
      def class_resource_type(resource)
        resource or return

        if !resource.is_a?(Class)
          return class_resource_type(resource.class)
        end

        klasses = []

        if resource.respond_to?(:base_class)
          # collect all classes between resource and base_class
          klass = resource
          loop do
            klasses << klass
            break if klass == resource.base_class
            klass = klass.superclass
          end

        else
          klasses << resource
        end

        klasses.map(&:to_s)
      end
    end
  end
end
