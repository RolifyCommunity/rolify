require 'active_record'

RSpec::Matchers::OperatorMatcher.register(ActiveRecord::Relation, '=~', RSpec::Matchers::BuiltIn::MatchArray)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Base.extend Rolify

load File.dirname(__FILE__) + '/../schema.rb'

# ActiveRecord models
class User < ActiveRecord::Base
  rolify
end

class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true

  extend Rolify::Adapter::Scopes
end

class Customer < ActiveRecord::Base
  rolify :role_cname => "Privilege"
end

class Privilege < ActiveRecord::Base
  has_and_belongs_to_many :customers, :join_table => :customers_privileges
  belongs_to :resource, :polymorphic => true

  extend Rolify::Adapter::Scopes
end

module Admin
  def self.table_name_prefix
    'admin_'
  end
  
  class Moderator < ActiveRecord::Base
    rolify :role_cname => "Admin::Right"
  end

  class Right < ActiveRecord::Base
    has_and_belongs_to_many :moderators, :class_name => "Admin::Moderator",:join_table => :admin_moderators_admin_rights
    belongs_to :resource, :polymorphic => true

    extend Rolify::Adapter::Scopes
  end  
end

class Forum < ActiveRecord::Base
  #resourcify done during specs setup to be able to use custom user classes
end

class Group < ActiveRecord::Base
  #resourcify done during specs setup to be able to use custom user classes

  def subgroups
    Group.where(:parent_id => id)
  end
end