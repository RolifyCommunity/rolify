shared_context "global role", :scope => :global do
  subject { admin }
  
  let(:admin) { Rolify.user_cname.first }
  
  before(:all) do
    load_roles
  end
  
  def load_roles
    Rolify.role_cname.destroy_all
    admin.roles = []
    admin.has_role "admin"
  end
end

shared_context "class scoped role", :scope => :class do
  subject { manager }
  
  before(:all) do
    load_roles
  end
  
  let(:manager) { Rolify.user_cname.where(:login => "moderator").first }
  
  def load_roles
    Rolify.role_cname.destroy_all
    manager.roles = []
    manager.has_role "manager", Forum
  end
end

shared_context "instance scoped role", :scope => :instance do
  subject { moderator }
  
  before(:all) do
    load_roles
  end
  
  let(:moderator) { Rolify.user_cname.where(:login => "god").first }
  
  def load_roles
    Rolify.role_cname.destroy_all
    moderator.roles = []
    moderator.has_role "moderator", Forum.first
  end
end

shared_context "with different roles" do 
  subject do
    user = Rolify.user_cname.where(:login => "zombie").first
    user.has_role "admin"
    user.has_role "anonymous"
    user.has_role "moderator", Forum.first
    user.has_role "visitor", Forum.last
    user.has_role "manager", Forum
    user.has_role "leader", Group
    Rolify.role_cname.create :name => "manager", :resource => Forum.first
    Rolify.role_cname.create :name => "manager", :resource => Forum.where(:name => "forum 2").first
    Rolify.role_cname.create :name => "manager", :resource => Forum.where(:name => "forum 3").first
    user
  end
end