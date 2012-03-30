shared_context "global role", :scope => :global do
  subject { admin }
  
  let(:admin) { user_class.first }
  
  before(:all) do
    load_roles
    create_other_roles
  end
  
  def load_roles
    role_class.destroy_all
    admin.roles = []
    admin.has_role "admin"
    admin.has_role "staff"
    admin.has_role "manager", Group
    admin.has_role "player", Forum
    admin.has_role "moderator", Forum.last
    admin.has_role "moderator", Group.last
    admin.has_role "anonymous", Forum.first
  end
end

shared_context "class scoped role", :scope => :class do
  subject { manager }
  
  before(:all) do
    load_roles
    create_other_roles
  end
  
  let(:manager) { user_class.where(:login => "moderator").first }
  
  def load_roles
    role_class.destroy_all
    manager.roles = []
    manager.has_role "manager", Forum
    manager.has_role "player", Forum 
    manager.has_role "warrior"
    manager.has_role "moderator", Forum.last
    manager.has_role "moderator", Group.last
    manager.has_role "anonymous", Forum.first
  end
end

shared_context "instance scoped role", :scope => :instance do
  subject { moderator }
  
  before(:all) do
    load_roles
    create_other_roles
  end
  
  let(:moderator) { user_class.where(:login => "god").first }
  
  def load_roles
    role_class.destroy_all
    moderator.roles = []
    moderator.has_role "moderator", Forum.first
    moderator.has_role "anonymous", Forum.last
    moderator.has_role "visitor", Forum
    moderator.has_role "soldier"
  end
end

def create_other_roles
  role_class.create :name => "superhero"
  role_class.create :name => "admin", :resource_type => "Group"
  role_class.create :name => "admin", :resource => Forum.first
  role_class.create :name => "VIP", :resource_type => "Forum"
  role_class.create :name => "manager", :resource => Forum.last
  role_class.create :name => "roomate", :resource => Forum.first
  role_class.create :name => "moderator", :resource => Group.first
end