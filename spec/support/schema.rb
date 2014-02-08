ActiveRecord::Schema.define do
  self.verbose = false

  [ :roles, :privileges, :admin_rights ].each do |table|
    create_table(table) do |t|
    t.string :name
    t.belongs_to :user
    t.references :resource, :polymorphic => true

    t.timestamps
    end
  end

  [ :users, :human_resources, :customers, :admin_moderators ].each do |table|
    create_table(table) do |t|
      t.string :login
    end
  end

  create_table(:forums) do |t|
    t.string :name
  end

  create_table(:groups) do |t|
    t.integer :parent_id
    t.string :name
  end
  
  create_table(:teams, :id => false) do |t|
    t.primary_key :team_code
    t.string :name
  end
end
