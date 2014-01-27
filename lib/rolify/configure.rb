module Rolify
  module Configure
    @@dynamic_shortcuts = false
    @@orm = "active_record"
     
    def configure(*role_cnames)
      return if !sanity_check(role_cnames)
      yield self if block_given?
    end

    def dynamic_shortcuts
      @@dynamic_shortcuts
    end

    def dynamic_shortcuts=(is_dynamic)
      @@dynamic_shortcuts = is_dynamic
    end

    def orm
      @@orm
    end

    def orm=(orm)
      @@orm = orm
    end

    def use_mongoid
      self.orm = "mongoid"
    end
    
    def use_dynamic_shortcuts
      self.dynamic_shortcuts = true
    end

    def use_defaults
      configure do |config|
        config.dynamic_shortcuts = false
        config.orm = "active_record"
      end
    end
    
    private
    
    def sanity_check(role_cnames)
      role_cnames = [ "Role" ] if role_cnames.empty?
      role_cnames.each do |role_cname|
        role_class = role_cname.constantize
        if role_class.superclass.to_s == "ActiveRecord::Base" && !role_class.table_exists?
          warn "[WARN] table '#{role_cname}' doesn't exist. Did you run the migration ? Ignoring rolify config."
          return false
        end
      end
      true
    end
  end
end