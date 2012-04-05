Rolify.configure do |config|
  # By default ORM adapter is ActiveRecord. uncomment to use mongoid
  <%= "# " if orm_adapter == "active_record" %>config.use_mongoid
  
  # Dynamic shortcuts for User class (user.is_admin? like methods). Default is: false
  <%= "# " if !options[:dynamic_shortcuts] %>config.use_dynamic_shortcuts
end