ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

load File.dirname(__FILE__) + '/../schema.rb'

# ActiveRecord models
class User < ActiveRecord::Base
  extend Rolify::Configuration
  rolify
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
  extend Rolify::Configuration
  rolify :role_cname => "Privilege"
end

class Privilege < ActiveRecord::Base
  has_and_belongs_to_many :customers, :join_table => :customers_privileges
  belongs_to :resource, :polymorphic => true
end