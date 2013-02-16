Rolify.configure<%= "(\"#{class_name.camelize.to_s}\")" if class_name != "Role" %> do |config|
  # By default ORM adapter is ActiveRecord. uncomment to use mongoid
  <%= "# " if options.orm == :active_record || !options.orm %>config.use_mongoid
  
  # Dynamic shortcuts for User class (user.is_admin? like methods). Default is: false
  # Enable this feature _after_ running rake db:migrate as it relies on the roles table
  # config.use_dynamic_shortcuts
end