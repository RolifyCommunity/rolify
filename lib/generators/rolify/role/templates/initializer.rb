Rolify.configure do |c|
  # User class to put the roles association. Default is: "User"
  <%= "# " if user_cname == "User" %>c.user_cname = "<%= user_cname %>"
  # Role class provided by Rolify. Default is: "Role"
  <%= "# " if role_cname == "Role" %>c.role_cname = "<%= role_cname %>"
  # By default ORM adapter is ActiveRecord. uncomment to use mongoid
  <%= "# " if orm_adapter == "active_record" %>c.use_mongoid
  # Dynamic shortcuts for Role class (user.is_admin? like methods). Default is: false
  <%= "# " if !options[:dynamic_shortcuts] %>c.dynamic_shortcuts = <%= options[:dynamic_shortcuts] == true ? true : false %> if defined?(Rails::Server) == true || defined?(Rails::Console) == true
end