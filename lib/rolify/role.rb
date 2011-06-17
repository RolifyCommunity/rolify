module Rolify

  def self.role_cname
    @@role_cname
  end

  def self.role_cname=(role_cname)
    @@role_cname = role_cname
  end

  def self.user_cname
    @@user_cname
  end

  def self.user_cname=(user_cname)
    @@user_cname = user_cname
  end


  module Roles

    def has_role(role_name, resource = nil)
      role = Rolify.role_cname.find_or_create_by_name_and_resource_type_and_resource_id( :name => role_name, 
                                                                                  :resource_type => (resource.class.name if resource), 
                                                                                  :resource_id => (resource.id if resource))
      if !roles.include?(role)
        self.class.define_dynamic_method role_name, resource
        self.roles << role
      end
    end
  
    def has_role?(role_name, resource = nil)
      query, values = build_query(role_name, resource)
      self.roles.where(*query, *values).size > 0
    end

    def has_all_roles?(*args)
      conditions = []
      values = []
      args.each do |arg|
        if arg.is_a? Hash
          return false if !self.has_role?(arg[:name], arg[:resource])
        elsif arg.is_a? String
          return false if !self.has_role?(arg)
        else
          raise ArgumentError, "Invalid argument type: only hash or string allowed"
        end
      end
      true
    end

    def has_any_role?(*args)
      conditions = []
      values = []
      args.each do |arg|
        if arg.is_a? Hash
          a, v = build_query(arg[:name], arg[:resource])
        elsif arg.is_a? String
          a, v = build_query(arg)
        else
          raise ArgumentError, "Invalid argument type: only hash or string allowed"
        end
        conditions << a
        values += v
      end
      self.roles.where([ conditions.join(' OR '), *values ]).size > 0
    end
  
    def has_no_role(role_name, resource = nil)
      role = self.roles.where( :name => role_name)
      role = role.where( :resource_type => resource.class.name,
                         :resource_id => resource.id) if resource
      self.roles.delete(role) if role
    end
  
    def roles_name
      self.roles.select(:name).map { |r| r.name }
    end
 
    private
 
    def build_query(role, resource = nil)
      query = "((name = ?) AND (resource_type IS NULL) AND (resource_id IS NULL))"
      values = [ role ]
      if resource
        query.insert(0, "(")
        query += " OR ((name = ?) AND (resource_type = ?) AND (resource_id = ?)))" 
        values << role << resource.class.name << resource.id
      end
      [ [ query ], values]
    end

  end

  module Reloaded
 
    def load_dynamic_methods
      role_cname.all.each do |r|
        define_dynamic_method(r.name, r.resource)
      end
    end


    def define_dynamic_method(role_name, resource)
      class_eval do 
        define_method("is_#{role_name}?".to_sym) do
        has_role?("#{role_name}")
        end if !method_defined? "is_#{role_name}?".to_sym
  
        define_method("is_#{role_name}_of?".to_sym) do |arg|
          has_role?("#{role_name}", arg)
        end if !method_defined?("is_#{role_name}_of?".to_sym) && resource
      end
    end
    
  end
end
