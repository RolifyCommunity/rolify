ActiveRecord::Schema.define do
  self.verbose = false

  create_table(:roles) do |t|
    t.string :name
    t.references :resource, :polymorphic => true

    t.timestamps
  end
  
  create_table(:users) do |t|
    t.string :login
  end

  create_table(:users_roles, :id => false) do |t|
    t.references :user
    t.references :role
  end
  
  create_table(:forums) do |t|
    t.string :name
  end
end