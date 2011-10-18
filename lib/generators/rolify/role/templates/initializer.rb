Rolify.user_cname = <%= user_cname.camelize %>
Rolify.role_cname = <%= role_cname.camelize %>
Rolify.dynamic_shortcuts = <%= options[:dynamic_shortcuts].to_s %> if defined? Rails::Server || defined? Rails::Console
