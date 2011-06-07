module Rolify
  def has_role(role, resource = nil)
    role = Role.find_or_create_by_name_and_resource_type_and_resource_id( :name => role, 
                                                                          :resource_type => (resource.class.name if resource), 
                                                                          :resource_id => (resource.id if resource))
    self.roles << role if !roles.include?(role)
  end
  
  def has_role?(role, resource = nil)
    query, values = build_query(role, resource)
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
