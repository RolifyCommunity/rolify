class RolifyCreate<%= table_name.camelize %> < ActiveRecord::Migration
  def change
    create_table(:<%= table_name %>) do |t|
      t.string :name
      t.belongs_to :user
      t.references :resource, :polymorphic => true

      t.timestamps
    end

    add_index(:<%= table_name %>, :name)
    add_index(:<%= table_name %>, [ :name, :resource_type, :resource_id ])
  end
end
