module Rolify
  module Finders
    def with_role(role_name, resource = nil)
      strict = self.strict_rolify && resource && resource != :any
      self.adapter.scope(
        self,
        { :name => role_name, :resource => resource },
        strict
      )
    end

    def without_role(role_name, resource = nil)
      self.adapter.all_except(self, self.with_role(role_name, resource))
    end

    def with_all_roles(*args)
      # Build a single query with all role conditions
      role_count = args.length
      self.adapter.scope(self, args, false)
        .group("#{table_name}.#{primary_key}")
        .having("COUNT(DISTINCT #{role_table}.id) = ?", role_count)
    end

    def with_any_role(*args)
      # Build a single query with OR conditions for all roles
      self.adapter.scope(self, args, false).distinct
    end
  end

  private

  def role_table
    self.role_class.table_name
  end
end
