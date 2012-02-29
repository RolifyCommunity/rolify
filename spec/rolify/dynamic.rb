shared_examples_for Rolify::Dynamic do 
  before(:all) do
    Rolify.user_cname = user_cname
    Rolify.dynamic_shortcuts = true
    Rolify.role_cname.destroy_all
    Rolify.user_cname.rolify :role_cname => role_cname
    Forum.resourcify :role_cname => role_cname
    Group.resourcify :role_cname => role_cname
  end
  
  before(:all) do
    @admin = Rolify.user_cname.first
    @admin.has_role "admin"
    @admin.has_role "moderator", Forum.first
  end
  
  before do
    @moderator = Rolify.user_cname.where(:login => "moderator").first
    @moderator.has_role "moderator", Forum.first
    @moderator.has_role "soldier"
  end
  
  before do
    @manager = Rolify.user_cname.where(:login => "god").first
    @manager.has_role "manager", Forum
    @manager.has_role "moderator", Forum.first
    @manager.has_role "moderator", Forum.last
    @manager.has_role "warrior"
  end
  
  it "should respond to dynamic methods" do
    @admin.should respond_to(:is_admin?).with(0).arguments
    @admin.should respond_to(:is_moderator_of?).with(1).arguments
  end
  
  it "should not respond to any unknown methods" do
    @admin.should_not respond_to(:is_god?)
  end
  
  it "should create a new dynamic method if role exists in database" do 
    other_guy = Rolify.user_cname.last
    other_guy.has_role "superman"
    @admin.should respond_to(:is_superman?).with(0).arguments
    other_guy.has_role("batman", Forum.first)
    @admin.should respond_to(:is_batman_of?).with(1).arguments
    @admin.should respond_to(:is_batman?).with(0).arguments
  end
  
  it "should be able to use dynamic shortcut" do 
    @admin.is_admin?.should be(true)
  end

  it "should be able to use dynamic shortcut" do 
    @moderator.is_moderator?.should be(false)
    @moderator.is_moderator_of?(Forum.first).should be(true)
    @moderator.is_moderator_of?(Forum.last).should be(false)
    @moderator.is_moderator_of?(Forum).should be(false)
  end

  it "should be able to use dynamic shortcut" do
    @manager.is_manager?.should be(false)
    @manager.is_manager_of?(Forum.first).should be(true)
    @manager.is_manager_of?(Forum.last).should be(true)
    @manager.is_manager_of?(Forum).should be(true)
    @manager.is_manager_of?(Group).should be(false)
  end
end