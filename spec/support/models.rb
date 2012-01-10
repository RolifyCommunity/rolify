# ActiveRecord models
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

# Mongoid models
class Muser
  include Mongoid::Document
  include Rolify::Roles
  extend Rolify::Dynamic
  has_and_belongs_to_many :mroles
  
  field :login, type: String
end

class Mrole
  include Mongoid::Document
  has_and_belongs_to_many :musers
  belongs_to :resource, :polymorphic => true
  
  field :name, type: String
end

class Mforum
  include Mongoid::Document
  
  field :name, type: String
end

class Mgroup
  include Mongoid::Document
  
  field :name, type: String
end

class Mcustomer
  include Mongoid::Document
  include Rolify::Roles
  extend Rolify::Dynamic
  has_and_belongs_to_many :roles, :class_name => "Mprivilege"
  
  field :login, type: String
end

class Mprivilege
  include Mongoid::Document
  has_and_belongs_to_many :mcustomers
  belongs_to :resource, :polymorphic => true
  
  field :name, type: String
end

#ActiveRecord::Base.instance_eval do
#  def using_object_ids?
#    false
#  end
#end