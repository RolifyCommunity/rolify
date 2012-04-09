module Rolify
  module Finders
    def with_role(role_name, resource = nil)
      self.adapter.scope(self, :name => role_name, :resource => resource)
    end

    def with_all_roles(*args)
      raise NotImplementedError.new("Not Implemented yet.") 
    end

    def with_any_role(*args)
      raise NotImplementedError.new("Not Implemented yet.")
    end
  end
end