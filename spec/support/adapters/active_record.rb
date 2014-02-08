require 'active_record'

RSpec::Matchers::OperatorMatcher.register(ActiveRecord::Relation, '=~', RSpec::Matchers::BuiltIn::MatchArray)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Base.extend Rolify

load File.dirname(__FILE__) + '/../schema.rb'

# Standard user and role classes
class User < ActiveRecord::Base
  rolify
end

class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :resource, :polymorphic => true

  extend Rolify::Adapter::Scopes
end

# Resourcifed and rolifed at the same time
class HumanResource < ActiveRecord::Base
  resourcify :resources
  rolify
end

# Custom role and class names
class Customer < ActiveRecord::Base
  rolify :role_cname => "Privilege"
end

class Privilege < ActiveRecord::Base
  belongs_to :customer
  belongs_to :resource, :polymorphic => true

  extend Rolify::Adapter::Scopes
end

# Namespaced models
module Admin
  def self.table_name_prefix
    'admin_'
  end

  class Moderator < ActiveRecord::Base
    rolify :role_cname => "Admin::Right"
  end

  class Right < ActiveRecord::Base
    belongs_to :moderator
    belongs_to :resource, :polymorphic => true

    extend Rolify::Adapter::Scopes
  end
end


# Resources classes
class Forum < ActiveRecord::Base
  #resourcify done during specs setup to be able to use custom user classes
end

class Group < ActiveRecord::Base
  #resourcify done during specs setup to be able to use custom user classes

  def subgroups
    Group.where(:parent_id => id)
  end
end

class Team < ActiveRecord::Base
  #resourcify done during specs setup to be able to use custom user classes
  self.primary_key = "team_code"
  
  default_scope { order(:team_code) }
end