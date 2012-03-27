Rolify.configure do |c|
  # By default ORM adapter is ActiveRecord. uncomment to use mongoid
  <%= "# " if orm_adapter == "active_record" %>c.use_mongoid
  
  # Dynamic shortcuts for Role class (user.is_admin? like methods). Default is: false
  <%= "# " if !options[:dynamic_shortcuts] %>c.dynamic_shortcuts = <%= options[:dynamic_shortcuts] == true ? true : false %> if defined?(Rails::Server) || defined?(Rails::Console)
end