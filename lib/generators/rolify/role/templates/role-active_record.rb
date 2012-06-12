class <%= role_cname.camelize %> < ActiveRecord::Base
  has_and_belongs_to_many :<%= user_cname.tableize %>, :join_table => :<%= "#{user_cname.tableize}_#{role_cname.tableize}" %>
  belongs_to :resource, :polymorphic => true
  
  scopify
end
