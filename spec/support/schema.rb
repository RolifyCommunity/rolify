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
  
  create_table(:groups) do |t|
    t.string :name
  end

  create_table(:privileges) do |t|
    t.string :name
    t.references :resource, :polymorphic => true
  end

  create_table(:customers) do |t|
    t.string :login
  end

  create_table(:customers_privileges, :id => false) do |t|
    t.references :customer
    t.references :privilege
  end
end
