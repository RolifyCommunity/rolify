shared_context "global role", :scope => :global do
  subject { admin }
  
  let(:admin) { Rolify.user_cname.first }
  
  before(:all) do
    load_roles
    create_other_roles
  end
  
  def load_roles
    Rolify.role_cname.destroy_all
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
  
  let(:manager) { Rolify.user_cname.where(:login => "moderator").first }
  
  def load_roles
    Rolify.role_cname.destroy_all
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
  
  let(:moderator) { Rolify.user_cname.where(:login => "god").first }
  
  def load_roles
    Rolify.role_cname.destroy_all
    moderator.roles = []
    moderator.has_role "moderator", Forum.first
    moderator.has_role "anonymous", Forum.last
    moderator.has_role "visitor", Forum
    moderator.has_role "soldier"
  end
end

def create_other_roles
  Rolify.role_cname.create :name => "superhero"
  Rolify.role_cname.create :name => "admin", :resource_type => "Group"
  Rolify.role_cname.create :name => "admin", :resource => Forum.first
  Rolify.role_cname.create :name => "VIP", :resource_type => "Forum"
  Rolify.role_cname.create :name => "manager", :resource => Forum.last
  Rolify.role_cname.create :name => "roomate", :resource => Forum.first
  Rolify.role_cname.create :name => "moderator", :resource => Group.first
end