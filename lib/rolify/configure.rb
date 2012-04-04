module Rolify
  module Configure
    @@dynamic_shortcuts = false
    @@orm = "active_record"
     
    def configure
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
      self.dynamic_shortcuts = true #if defined?(Rails::Server) || defined?(Rails::Console)
    end

    def use_defaults
      configure do |config|
        config.dynamic_shortcuts = false
        config.orm = "active_record"
      end
    end
  end
end