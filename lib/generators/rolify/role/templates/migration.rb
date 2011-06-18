class RolifyCreate<%= role_cname.pluralize.camelize %> < ActiveRecord::Migration
  def change
    create_table(:<%= role_cname.tableize %>) do |t|
      t.string :name
      t.references :resource, :polymorphic => true

      t.timestamps
    end

    create_table(:<%= (user_cname.tableize + "_" + role_cname.tableize) %>, :id => false) do |t|
      t.references :<%= user_cname.underscore.singularize %>
      t.references :<%= role_cname.underscore.singularize %>
    end

    add_index(:<%= role_cname.tableize %>, :name)
    add_index(:<%= role_cname.tableize %>, [ :name, :resource_type, :resource_id ])
    add_index(:<%= "#{user_cname.tableize}_#{role_cname.tableize}" %>, [ :<%= user_cname.underscore.singularize %>_id, :<%= role_cname.underscore.singularize %>_id ])
  end
end
