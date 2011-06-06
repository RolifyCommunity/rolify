module Rolify
  def has_role(role, resource = nil)
    role = Role.find_or_create_by_name_and_resource_type_and_resource_id( :name => role, 
                                                                          :resource_type => (resource.class.name if resource), 
                                                                          :resource_id => (resource.id if resource))
    self.roles << role if !roles.include?(role)
  end
  
  def has_role?(role, resource = nil)
    global_role_query = "((name = ?) AND (resource_type IS NULL) AND (resource_id IS NULL))"
    if resource
      self.roles.where("#{global_role_query} OR ((name = ?) AND (resource_type = ?) AND (resource_id = ?))", 
                        role, role, resource.class.name, resource.id).size > 0
    else
      self.roles.where(global_role_query, role).size > 0
    end
  end

  def has_all_roles?(*args)
    
  end

  def has_any_role?(*args)

  end
  
  def roles_name
    self.roles.select(:name).map { |r| r.name }
  end
end
