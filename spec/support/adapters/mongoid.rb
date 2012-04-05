require 'mongoid'

Mongoid.configure do |config|
  config.master = Mongo::Connection.new.db("godfather")
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

class Role
  include Mongoid::Document
  has_and_belongs_to_many :users
  belongs_to :resource, :polymorphic => true
  
  field :name, :type => String
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
end
