module Rolify
  
  module Adapter
    
    class Mongoid < Adapter::Base
      
      def self.find(relation, role_name, resource)
        query = build_query(role_name, resource)
        query.each do |condition|
          criteria = relation.where(condition)
          return criteria.all if !criteria.empty?
        end
        []
      end
      
      def self.where(relation, args)
        conditions = build_conditions(relation, args)
        relation.any_of(*conditions)
      end
      
      def self.find_or_create_by(role_name, resource_type = nil, resource_id = nil)
        Rolify.role_cname.find_or_create_by(:name => role_name, 
                                            :resource_type => resource_type, 
                                            :resource_id => resource_id)
      end
      
      def self.add(relation, role)
        relation.roles << role
      end
      
      def self.remove(relation, role_name, resource = nil)
        role = { :name => role_name }
        role.merge!({:resource_type => (resource.is_a?(Class) ? resource.to_s : resource.class.name)}) if resource
        role.merge!({ :resource_id => resource.id }) if resource && !resource.is_a?(Class)
        relation.where(role).destroy_all
      end
      
      def self.resources_find(roles_table, relation, role_name)
        roles = roles_table.classify.constantize.where(:resource_type => relation.to_s)
#        puts "#{roles.all.map{|r| [r.id, r.name]}.inspect} | #{relation.count}"
        result = relation.where(:"#{roles_table}.name" => role_name) #.where(:"#{roles_table}.id".in => roles.map{ |r| r.id })
#        puts "#{result.all.map{|r| r.name}.inspect} xD"
        result
      end
      
      def self.in(relation, roles)
#        puts "#{relation.all.map{|r| r.name}.inspect} | #{roles.inspect}"
        result = relation.where(:"#{Rolify.role_cname.to_s.tableize}.id".in => roles.map{ |r| r.id })
#        puts "#{result.map{|r| r.name}.inspect}"
        result
      end
      
      private
      
      def self.build_conditions(relation, args)
        conditions = []
        args.each do |arg|
          if arg.is_a? Hash
            query = build_query(arg[:name], arg[:resource])
          elsif arg.is_a? String
            query = build_query(arg)
          else
            raise ArgumentError, "Invalid argument type: only hash or string allowed"
          end
          conditions += query
        end
        conditions
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