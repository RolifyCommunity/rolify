class <%= role_cname.camelize %> < ActiveRecord::Base
  has_and_belongs_to_many :<%= user_cname.tableize %>, :join_table => :<%= "#{user_cname.tableize}_#{role_cname.tableize}" %>
  belongs_to :resource, :polymorphic => true
  
  scope :global, where(:resource_type => nil, :resource_id => nil)
  scope :class_scoped, where("resource_type IS NOT NULL AND resource_id IS NULL")
  scope :instance_scoped, where("resource_type IS NOT NULL AND resource_id IS NOT NULL")
end
