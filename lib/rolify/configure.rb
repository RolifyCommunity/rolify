module Rolify
  module Configure
    @@role_cname = "Role"
    @@user_cname = "User"
    @@dynamic_shortcuts = false
    @@orm = "active_record"
     
    def configure
      yield self if block_given?
    end

    def role_cname
      @@role_cname.constantize
    end

    def role_cname=(role_cname)
      @@role_cname = role_cname.camelize
    end

    def user_cname
      @@user_cname.constantize
    end

    def user_cname=(user_cname)
      @@user_cname = user_cname.camelize
    end

    def dynamic_shortcuts
      @@dynamic_shortcuts || false
    end

    def dynamic_shortcuts=(is_dynamic)
      @@dynamic_shortcuts = is_dynamic
    end

    def orm
      @@orm
    end

    def orm=(orm)
      @@orm = orm
      @@adapter = Rolify::Adapter.const_get(orm.camelize)
    end

    def adapter
      @@adapter ||= Rolify::Adapter::ActiveRecord
    end

    def use_mongoid
      self.orm = "mongoid"
    end

    def use_defaults
      @@role_cname = "Role"
      @@user_cname = "User"
      @@dynamic_shortcuts = false
      @@orm = "active_record"
      @@adapter = Rolify::Adapter::ActiveRecord
    end
  end
end