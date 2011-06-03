class RolifyCreate<%= role_cname.camelize %> < ActiveRecord::Migration
  def change
    create_table(<%= role_cname.tableize.to_sym %>) do |t|
      t.string :name
      t.references :resource, :polymorphic => true

      t.timestamps
    end

    create_table(<%= (user_cname.tableize + "_" + role_cname.tableize).to_sym %>, :id => false) do |t|
      t.references :<%= user_cname.underscore.singularize %>
      t.references :<%= role_cname.underscore.singularize %>
    end
  end
end
