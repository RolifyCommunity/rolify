class <%= role_cname.camelize %>
  include Mongoid::Document
  
  has_and_belongs_to_many :<%= user_cname.tableize %>
  belongs_to :resource, :polymorphic => true
  
  field :name, :type => String
end
