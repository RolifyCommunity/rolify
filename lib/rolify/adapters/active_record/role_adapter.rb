require 'rolify/adapters/base'

module Rolify
  module Adapter
    class RoleAdapter < RoleAdapterBase
      def where(relation, *args)
        conditions, values = build_conditions(relation, args)
        relation.where(conditions, *values)
      end

      def where_strict(relation, args)
        return relation.where(:name => args[:name]) if args[:resource].blank?
        resource = if args[:resource].is_a?(Class)
                     {class: args[:resource].to_s, id: nil}
                   else
                     {class: args[:resource].class.name, id: args[:resource].id}
                   end

        relation.where(:name => args[:name], :resource_type => resource[:class], :resource_id => resource[:id])
      end

      def find_cached(relation, args)
        resource_id = (args[:resource].nil? || args[:resource].is_a?(Class) || args[:resource] == :any) ? nil : args[:resource].id
        resource_type = args[:resource].is_a?(Class) ? args[:resource].to_s : args[:resource].class.name

        return relation.find_all { |role| role.name == args[:name].to_s } if args[:resource] == :any

        relation.find_all do |role|
          (role.name == args[:name].to_s && role.resource_type == nil && role.resource_id == nil) ||
          (role.name == args[:name].to_s && role.resource_type == resource_type && role.resource_id == nil) ||
          (role.name == args[:name].to_s && role.resource_type == resource_type && role.resource_id == resource_id)
        end
      end

      def find_cached_strict(relation, args)
        resource_id = (args[:resource].nil? || args[:resource].is_a?(Class)) ? nil : args[:resource].id
        resource_type = args[:resource].is_a?(Class) ? args[:resource].to_s : args[:resource].class.name

        relation.find_all do |role|
          role.resource_id == resource_id && role.resource_type == resource_type && role.name == args[:name].to_s
        end
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
            role.destroy if role.send(ActiveSupport::Inflector.demodulize(user_class).tableize.to_sym).limit(1).empty?
          end if Rolify.remove_role_if_empty
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

      def all_except(user, excluded_obj)
        prime_key = user.primary_key.to_sym
        user.where(prime_key => (user.all - excluded_obj).map(&prime_key))
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
