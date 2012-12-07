require 'mongoid'

Mongoid.load!("spec/support/adapters/mongoid.yml", :test)

RSpec.configure do |config|
  config.include Mongoid::Matchers
end

::Mongoid::Document.module_eval do
  def self.included(base)
    base.extend Rolify
  end
end

Rolify.use_mongoid

# Mongoid models
class User
  include Mongoid::Document
  rolify

  field :login, :type => String
end

# Resourcifed and rolifed at the sametime
class SUser
  include Mongoid::Document
  resourcify
  rolify

  field :login, :type => String
end

class Role
  include Mongoid::Document
  has_and_belongs_to_many :users
  belongs_to :resource, :polymorphic => true

  field :name, :type => String
  index(
    {
      :name => 1,
      :resource_type => 1,
      :resource_id => 1
    },
    { :unique => true }
  )

  scopify
end

class Customer
  include Mongoid::Document
  rolify :role_cname => "Privilege"

  field :login, :type => String
end

class Privilege
  include Mongoid::Document
  has_and_belongs_to_many :customers
  belongs_to :resource, :polymorphic => true

  field :name, :type => String
  index(
    {
      :name => 1,
      :resource_type => 1,
      :resource_id => 1
    },
    { :unique => true }
  )

  scopify
end

module Admin
  class Moderator
    include Mongoid::Document
    rolify :role_cname => "Admin::Right"

    field :login, :type => String
  end

  class Right
    include Mongoid::Document
    has_and_belongs_to_many :moderators, :class_name => 'Admin::Moderator'
    belongs_to :resource, :polymorphic => true

    field :name, :type => String
    index(
      {
        :name => 1,
        :resource_type => 1,
        :resource_id => 1
      },
      { :unique => true }
    )

    scopify
  end
end

class Forum
  include Mongoid::Document
  #resourcify done during specs setup to be able to use custom user classes

  field :name, :type => String
end

class Group
  include Mongoid::Document
  #resourcify done during specs setup to be able to use custom user classes

  field :name, :type => String
  field :parent_id, :type => Integer

  def subgroups
    Group.in(:parent_id => _id)
  end
end
