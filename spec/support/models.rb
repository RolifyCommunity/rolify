class User < ActiveRecord::Base
  has_and_belongs_to_many :roles, :join_table => :users_roles
  include Rolify
end

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
end

class Forum < ActiveRecord::Base
end