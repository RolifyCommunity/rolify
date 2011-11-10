class User < ActiveRecord::Base
  has_and_belongs_to_many :roles, :join_table => :users_roles
  include Rolify::Roles
  extend Rolify::Dynamic
end

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
end

class Forum < ActiveRecord::Base
end

class Group < ActiveRecord::Base
end

class Customer < ActiveRecord::Base
  has_and_belongs_to_many :roles, :join_table => :customers_privileges, :class_name => "Privilege"
  include Rolify::Roles
  extend Rolify::Dynamic
end

class Privilege < ActiveRecord::Base
  has_and_belongs_to_many :customers, :join_table => :customers_privileges
  belongs_to :resource, :polymorphic => true
end

