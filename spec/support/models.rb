# ActiveRecord models
Rolify.orm = "active_record"
class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
end

class User < ActiveRecord::Base  
  extend Rolify::Configuration
end

class Forum < ActiveRecord::Base
end

class Group < ActiveRecord::Base
end

class Customer < ActiveRecord::Base
  extend Rolify::Configuration
end

class Privilege < ActiveRecord::Base
  has_and_belongs_to_many :customers, :join_table => :customers_privileges
  belongs_to :resource, :polymorphic => true
end

Rolify.orm = "mongoid"
# Mongoid models
class Muser
  include Mongoid::Document
  extend Rolify::Configuration
  rolify :role_cname => "Mrole"
  
  field :login, :type => String
end

class Mrole
  include Mongoid::Document
  has_and_belongs_to_many :users, :class_name => "Muser"
  belongs_to :resource, :polymorphic => true
  
  field :name, :type => String
end

class Mforum
  include Mongoid::Document
  
  field :name, :type => String
end

class Mgroup
  include Mongoid::Document
  
  field :name, :type => String
end

class Mcustomer
  include Mongoid::Document
  extend Rolify::Configuration
  rolify :role_cname => "Mprivilege"
  
  field :login, :type => String
end

class Mprivilege
  include Mongoid::Document
  has_and_belongs_to_many :mcustomers
  belongs_to :resource, :polymorphic => true
  
  field :name, :type => String
end
Rolify.orm = "active_record"