ActiveRecord::Schema.define do
  self.verbose = false

  [ :roles, :admin_roles ].each do |table|
    create_table(table) do |t|
    t.string :name
    t.references :resource, :polymorphic => true
  
    t.timestamps
    end
  end

  [ :users, :admin_users ].each do |table|
    create_table(table) do |t|
      t.string :login
    end
  end

  [ :users_roles, :admin_users_admin_roles ].each do |table|
    create_table(table, :id => false) do |t|
      t.references :user
      t.references :role
    end
  end

  create_table(:forums) do |t|
    t.string :name
  end

  create_table(:groups) do |t|
    t.integer :parent_id
    t.string :name
  end

  [ :privileges, :admin_privileges ].each do |table|
    create_table(table) do |t|
      t.string :name
      t.references :resource, :polymorphic => true
    end
  end

  [ :customers, :admin_customers ].each do |table|
    create_table(table) do |t|
      t.string :login
    end
  end

  [ :customers_privileges, :admin_customers_admin_privileges ].each do |table|
    create_table(table, :id => false) do |t|
      t.references :customer
      t.references :privilege
    end
  end
end
