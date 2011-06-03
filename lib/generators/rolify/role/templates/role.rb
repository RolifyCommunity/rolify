class <%= role_cname.camelize %> < ActiveRecord::Base
  has_and_belongs_to_many :<%= user_cname.tableize %>
end
