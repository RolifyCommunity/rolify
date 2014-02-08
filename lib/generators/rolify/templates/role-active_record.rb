class <%= role_cname.camelize %> < ActiveRecord::Base
<% if need_table_prefix?(role_cname) %>
  def self.table_name_prefix
    <%= table_prefix(role_cname) %>_
  end
<% end %>
  belongs_to <%= user_cname.singularize %>
  belongs_to :resource, :polymorphic => true

  scopify
end
