require "spec_helper"

shared_examples_for "Rolify module" do |dynamic|
  before(:all) do
    Rolify.user_cname = user_cname
    Rolify.role_cname = role_cname
    Rolify.dynamic_shortcuts = dynamic_shortcuts
    Rolify.role_cname.destroy_all
  end
  
  context "in a Instance level" do 
    before(:all) do
      @admin = Rolify.user_cname.first
      @admin.has_role "admin"
      @admin.has_role "moderator", Forum.first
    end

    it "should respond to has_role method" do 
      @admin.should respond_to(:has_role).with(1).arguments
      @admin.should respond_to(:has_role).with(2).arguments
    end

    it "should respond to has_role? method" do
      @admin.should respond_to(:has_role?).with(1).arguments
      @admin.should respond_to(:has_role?).with(2).arguments
    end

    it "should respond to has_all_roles? method" do
      @admin.should respond_to(:has_all_roles?)
      @admin.should respond_to(:has_all_roles?)
    end

    it "should respond to has_any_role? method" do
      @admin.should respond_to(:has_any_role?)
      @admin.should respond_to(:has_any_role?)
    end

    it "should respond to has_no_role method" do
      @admin.should respond_to(:has_no_role).with(1).arguments
      @admin.should respond_to(:has_no_role).with(2).arguments
    end

    it "should respond to dynamic methods", :if => dynamic do
      @admin.should respond_to(:is_admin?).with(0).arguments
      @admin.should respond_to(:is_moderator_of?).with(1).arguments
    end

    it "should not respond to any unknown methods", :if => dynamic do
      @admin.should_not respond_to(:is_god?)
    end

    it "should create a new dynamic method if role exists in database", :if => dynamic do 
      Rolify.role_cname.create(:name => "superman")
      @admin.should respond_to(:is_superman?).with(0).arguments
      Rolify.role_cname.create(:name => "batman", :resource => Forum.first)
      @admin.should respond_to(:is_batman_of?).with(1).arguments
      @admin.should respond_to(:is_batman?).with(0).arguments
    end

    it "should not have any dynamic methods if dynamic_shortcuts is disabled", :if => dynamic == false do
      @admin.should_not respond_to(:is_admin?)
      @admin.should_not respond_to(:is_moderator_of?)
    end
  end

  context "with a global role" do 
    before do
      @admin = Rolify.user_cname.first
      @admin.has_role "admin"
      @admin.has_role "staff"
      @admin.has_role "moderator", Forum.first
      @admin.has_role "moderator", Forum.find(2)
      @admin.has_role "manager", Group
    end

    it "should set a global role" do
      expect { @admin.has_role "superadmin" }.to change{ Rolify.role_cname.count }.by(1)
      superadmin = Rolify.role_cname.last
      superadmin.name.should eq("superadmin")
      superadmin.resource.should be(nil)
    end

    it "should not create another role if already existing" do
      expect { @admin.has_role "admin" }.not_to change{ Rolify.role_cname.count }
      expect { @admin.has_role "admin" }.not_to change{ @admin.roles.size }
    end

    it "should get a global role" do
      @admin.has_role?("admin").should be(true)
    end

    it "should be able to use dynamic shortcut", :if => dynamic do
      @admin.is_admin?.should be(true)
      @admin.is_evil?.should be(false)
    end

    it "should get any resource request" do
      @admin.has_role?("admin", Forum.first).should be(true)
      @admin.has_role?("admin", Forum).should be(true)
      @admin.has_role?("admin", :any).should be(true)
    end

    it "should not get another global role" do
      Rolify.role_cname.create(:name => "global")
      @admin.has_role?("global").should be(false)
      @admin.has_role?("global", :any).should be(false)
    end

    it "should not get an instance scoped role" do
      @admin.has_role?("moderator", Forum.last).should be(false)
    end

    it "should not get a class scoped role" do
      @admin.has_role?("manager", Forum).should be(false)
    end

    it "should not get inexisting role" do
      @admin.has_role?("dummy").should be(false)
      @admin.has_role?("dumber", Forum.first).should be(false)
    end

    it "should check if user has all of a global roles set" do
      @admin.has_all_roles?("staff").should be(true)
      @admin.has_all_roles?("admin", "staff").should be(true)
      @admin.has_all_roles?("admin", "dummy").should be(false)
      @admin.has_all_roles?("dummy", "dumber").should be(false)
    end

    it "should check if user has any of a global roles set" do
      @admin.has_any_role?("staff").should be(true)
      @admin.has_any_role?("admin", "staff").should be(true)
      @admin.has_any_role?("admin", "moderator").should be(true)
      @admin.has_any_role?("dummy", "dumber").should be(false)
    end

    it "should remove a global role of a user" do 
      expect { @admin.has_no_role("admin") }.to change{ @admin.roles.size }.by(-1)
      @admin.has_role?("admin").should be(false)
      @admin.has_role?("staff").should be(true)
      @admin.has_role?("moderator", Forum.first).should be(true)
      @admin.has_role?("manager", Group).should be(true)
    end

    it "should remove a class scoped role of a user" do
      expect { @admin.has_no_role("manager") }.to change{ @admin.roles.size }.by(-1)
      @admin.has_role?("staff").should be(true)
      @admin.has_role?("moderator", Forum.first).should be(true)
      @admin.has_role?("manager", Group).should be(false)
    end
    
    it "should remove two instance scoped roles of a user" do
      expect { @admin.has_no_role("moderator") }.to change{ @admin.roles.size }.by(-2)
      @admin.has_role?("staff").should be(true)
      @admin.has_role?("moderator", Forum.first).should be(false)
      @admin.has_role?("moderator", Forum.find(2)).should be(false)
      @admin.has_role?("manager", Group).should be(true)
    end

    it "should not remove another global role" do 
      expect { @admin.has_no_role("global") }.not_to change{ @admin.roles.size }
    end
  end

  context "with an instance scoped role" do
    before do
      @moderator = Rolify.user_cname.find(2)
      @moderator.has_role "moderator", Forum.first
      @moderator.has_role "soldier"
    end

    it "should set an instance scoped role" do
      expect { @moderator.has_role "visitor", Forum.last }.to change{ Rolify.role_cname.count }.by(1)
      visitor = Rolify.role_cname.last
      visitor.name.should eq("visitor")
      visitor.resource.should eq(Forum.last)
    end

    it "should not create another role if already existing" do
      expect { @moderator.has_role "moderator", Forum.first }.not_to change{ Rolify.role_cname.count }
      expect { @moderator.has_role "moderator", Forum.first }.not_to change{ @moderator.roles.size }
    end

    it "should get an instance scoped role" do
      @moderator.has_role?("moderator", Forum.first).should be(true)
    end

    it "should get any of instance scoped role" do
      @moderator.has_role?("moderator", :any).should be(true)
    end

    it "should not get an instance scoped role when asking for a global" do
      @moderator.has_role?("moderator").should be(false)
    end

    it "should not get an instance scoped role when asking for a class scoped" do 
      @moderator.has_role?("moderator", Forum).should be(false)
    end

    it "should be able to use dynamic shortcut", :if => dynamic do
      @moderator.is_moderator?.should be(false)
      @moderator.is_moderator_of?(Forum.first).should be(true)
      @moderator.is_moderator_of?(Forum.last).should be(false)
      @moderator.is_moderator_of?(Forum).should be(false)
    end

    it "should not get a global role" do
      @moderator.has_role?("admin").should be(false)
    end

    it "should not get the same role on another resource" do
      Rolify.role_cname.create(:name => "moderator", :resource => Forum.last)
      @moderator.has_role?("moderator", Forum.last).should be(false)
    end

    it "should not get the another role on the same resource" do
      Rolify.role_cname.create(:name => "tourist", :resource => Forum.first)
      @moderator.has_role?("tourist", Forum.first).should be(false)
      @moderator.has_role?("tourist", :any).should be(false)
    end

    it "should not get inexisting role" do
      @moderator.has_role?("dummy", Forum.last).should be(false)
      @moderator.has_role?("dumber").should be(false)
    end

    it "should check if user has all of a scoped roles set" do
      @moderator.has_all_roles?({ :name => "visitor", :resource => Forum.last }).should be(true)
      @moderator.has_all_roles?({ :name => "moderator", :resource => Forum.first }, 
      { :name => "visitor", :resource => Forum.last }).should be(true)
      @moderator.has_all_roles?({ :name => "moderator", :resource => Forum.first }, 
      { :name => "dummy", :resource => Forum.last }).should be(false)
      @moderator.has_all_roles?({ :name => "dummy", :resource => Forum.first }, 
      { :name => "dumber", :resource => Forum.last }).should be(false)
    end

    it "should check if user has any of a scoped roles set" do
      @moderator.has_any_role?( { :name => "visitor", :resource => Forum.last }).should be(true)
      @moderator.has_any_role?( { :name => "moderator", :resource => Forum.first }, 
      { :name => "visitor", :resource => Forum.last }).should be(true)
      @moderator.has_any_role?( { :name => "moderator", :resource => Forum.first }, 
      { :name => "dummy", :resource => Forum.last }).should be(true)
      @moderator.has_any_role?( { :name => "dummy", :resource => Forum.first }, 
      { :name => "dumber", :resource => Forum.last }).should be(false)
    end

    it "should not remove a global role of a user" do 
      expect { @moderator.has_no_role("soldier", Forum.first) }.not_to change{ @moderator.roles.size }
    end

    it "should remove a scoped role of a user" do 
      expect { @moderator.has_no_role("moderator", Forum.first) }.to change{ @moderator.roles.size }.by(-1)
      @moderator.has_role?("moderator", Forum.first).should be(false)
      @moderator.has_role?("soldier").should be(true)
    end

    it "should not remove another scoped role" do
      expect { @moderator.has_no_role("visitor", Forum.first) }.not_to change{ @moderator.roles.size }
    end
  end

  context "with a class scoped role" do
    before do
      @manager = Rolify.user_cname.find(3)
      @manager.has_role "manager", Forum
      @manager.has_role "moderator", Forum.first
      @manager.has_role "moderator", Forum.last
      @manager.has_role "warrior"
    end

    it "should set a class scoped role" do
      expect { @manager.has_role "player", Forum }.to change{ Rolify.role_cname.count }.by(1)
      player = Rolify.role_cname.last
      player.name.should eq("player")
      player.resource_type.should eq(Forum.to_s)
    end

    it "should not create another role if already existing" do
      expect { @manager.has_role "manager", Forum }.not_to change{ Rolify.role_cname.count }
      expect { @manager.has_role "manager", Forum }.not_to change{ @manager.roles.size }
    end

    it "should get a class scoped role" do
      @manager.has_role?("manager", Forum).should be(true)
      @manager.has_role?("manager", Forum.first).should be(true)
    end

    it "should get any of class scoped role" do
      @manager.has_role?("manager", :any).should be(true)
    end

    it "should not get a scoped role when asking for a global" do
      @manager.has_role?("manager").should be(false)
    end

    it "should be able to use dynamic shortcut", :if => dynamic do
      @manager.is_manager?.should be(false)
      @manager.is_manager_of?(Forum.first).should be(true)
      @manager.is_manager_of?(Forum.last).should be(true)
      @manager.is_manager_of?(Forum).should be(true)
      @manager.is_manager_of?(Group).should be(false)
    end

    it "should not get a global role" do
      @manager.has_role?("admin").should be(false)
    end

    it "should not get the same role on another resource" do
      Rolify.role_cname.create(:name => "manager", :resource_type => "Group")
      @manager.has_role?("manager", Group).should be(false)
    end

    it "should not get the another role on the same resource" do
      Rolify.role_cname.create(:name => "member", :resource_type => "Forum")
      @manager.has_role?("member", Forum).should be(false)
      @manager.has_role?("member", :any).should be(false)
    end

    it "should not get inexisting role" do
      @manager.has_role?("dummy", Forum).should be(false)
      @manager.has_role?("dumber").should be(false)
    end

    it "should check if user has all of a scoped roles set" do
      @manager.has_all_roles?({ :name => "player", :resource => Forum }).should be(true)
      @manager.has_all_roles?({ :name => "manager", :resource => Forum }, 
      { :name => "player", :resource => Forum }).should be(true)
      @manager.has_all_roles?({ :name => "manager", :resource => Forum }, 
      { :name => "dummy", :resource => Forum }).should be(false)
      @manager.has_all_roles?({ :name => "dummy", :resource => Forum }, 
      { :name => "dumber", :resource => Group }).should be(false)
    end

    it "should check if user has any of a scoped roles set" do
      @manager.has_any_role?( { :name => "player", :resource => Forum }).should be(true)
      @manager.has_any_role?( { :name => "manager", :resource => Forum }, 
      { :name => "player", :resource => Forum }).should be(true)
      @manager.has_any_role?( { :name => "manager", :resource => Forum }, 
      { :name => "dummy", :resource => Forum }).should be(true)
      @manager.has_any_role?( { :name => "dummy", :resource => Forum }, 
      { :name => "dumber", :resource => Group }).should be(false)
    end

    it "should not remove a global role of a user" do 
      expect { @manager.has_no_role("warrior", Forum) }.not_to change{ @manager.roles.size }
    end

    it "should remove a class scoped role of a user" do 
      expect { @manager.has_no_role("manager", Forum) }.to change{ @manager.roles.size }.by(-1)
      @manager.has_role?("manager", Forum).should be(false)
      @manager.has_role?("moderator", Forum.first).should be(true)
      @manager.has_role?("moderator", Forum.last).should be(true)
      @manager.has_role?("warrior").should be(true)
    end
    
    it "should remove two instance scoped roles of a user" do 
      expect { @manager.has_no_role("moderator", Forum) }.to change{ @manager.roles.size }.by(-2)
      @manager.has_role?("manager", Forum).should be(true)
      @manager.has_role?("moderator", Forum.first).should be(false)
      @manager.has_role?("moderator", Forum.last).should be(false)
      @manager.has_role?("warrior").should be(true)
    end

    it "should not remove another scoped role" do
      expect { @manager.has_no_role("visitor", Forum.first) }.not_to change{ @manager.roles.size }
    end
  end

  context "with different roles" do 
    before do 
      @user = Rolify.user_cname.find(4)
      @user.has_role "admin"
      @user.has_role "anonymous"
      @user.has_role "moderator", Forum.first
      @user.has_role "visitor", Forum.last
      @user.has_role "manager", Forum
      @user.has_role "leader", Group
      Rolify.role_cname.create :name => "manager", :resource => Forum.find(1)
      Rolify.role_cname.create :name => "manager", :resource => Forum.find(2)
      Rolify.role_cname.create :name => "manager", :resource => Forum.find(3)
    end

    it "should get a global role" do
      @user.has_role?("admin").should be(true)
      @user.has_role?("anonymous").should be(true)
    end

    it "should get an instance scoped role" do
      @user.has_role?("moderator", Forum.first).should be(true)
      @user.has_role?("visitor", Forum.last).should be(true)
    end

    it "should get an class scoped role" do
      @user.has_role?("manager", Forum).should be(true)
      @user.has_role?("leader", Group).should be(true)
    end

    it "should check if user has all of a mix of global and scoped roles set" do
      @user.has_all_roles?("admin", { :name => "moderator", :resource => Forum.first }, { :name => "manager", :resource => Forum }).should be(true)
      @user.has_all_roles?("admin", { :name => "moderator", :resource => Forum.last }, { :name => "manager", :resource => Forum }).should be(false)
      @user.has_all_roles?("admin", { :name => "moderator", :resource => Forum.first }, { :name => "manager", :resource => Group }).should be(false)
      @user.has_all_roles?("admin", { :name => "moderator", :resource => Forum.first }, { :name => "manager", :resource => Group.first }).should be(false)
      @user.has_all_roles?({ :name => "admin", :resource => Forum }, { :name => "moderator", :resource => Forum.first }, { :name => "manager", :resource => Forum }).should be(true)
      @user.has_all_roles?({ :name => "admin", :resource => Forum.first }, { :name => "moderator", :resource => Forum.first }, { :name => "manager", :resource => Forum }).should be(true)
      @user.has_all_roles?("admin", { :name => "moderator", :resource => Forum.first }, { :name => "manager", :resource => Forum.first }).should be(true)
      @user.has_all_roles?("dummy", { :name => "dumber", :resource => Forum.last }, { :name => "dumberer", :resource => Forum }).should be(false)
      @user.has_all_roles?("admin", "dummy", { :name => "dumber", :resource => Forum.last }, { :name => "dumberer", :resource => Forum }).should be(false)
      @user.has_all_roles?({ :name => "manager", :resource => Forum.last }, "dummy", { :name => "dumber", :resource => Forum.last }, { :name => "dumberer", :resource => Forum }).should be(false)
      @user.has_all_roles?("admin", { :name => "dumber", :resource => Forum.last }, { :name => "manager", :resource => Forum.last })
      @user.has_all_roles?({ :name => "admin", :resource => Forum.first }, { :name => "moderator", :resource => Forum.first }, { :name => "manager", :resource => Forum.last })
    end

    it "should check if user has any of a mix of global and scoped roles set" do
      @user.has_any_role?("admin", { :name => "moderator", :resource => Forum.first }, { :name => "manager", :resource => Forum }).should be(true)
      @user.has_any_role?("admin", { :name => "moderator", :resource => Forum.last }, { :name => "manager", :resource => Forum }).should be(true)
      @user.has_any_role?("admin", { :name => "moderator", :resource => Forum.last }, { :name => "manager", :resource => Group }).should be(true)
      @user.has_any_role?("admin", { :name => "moderator", :resource => Forum.last }, { :name => "manager", :resource => Group.first }).should be(true)
      @user.has_any_role?({ :name => "admin", :resource => Forum }, { :name => "moderator", :resource => Forum.last }, { :name => "manager", :resource => Forum }).should be(true)
      @user.has_any_role?({ :name => "admin", :resource => Forum.first }, { :name => "moderator", :resource => Forum.last }, { :name => "manager", :resource => Forum }).should be(true)
      @user.has_any_role?("admin", { :name => "moderator", :resource => Forum.last }, { :name => "manager", :resource => Forum.first }).should be(true)
      @user.has_any_role?("dummy", { :name => "dumber", :resource => Forum.last }, { :name => "dumberer", :resource => Forum }).should be(false)
      @user.has_any_role?({ :name => "manager", :resource => Forum.last }, "dummy", { :name => "dumber", :resource => Forum.last }, { :name => "dumberer", :resource => Forum }).should be(true)
    end
  end

end

describe Rolify do
  context "using default Role and User class names with dynamic shortcuts", true do 
    it_behaves_like "Rolify module" do
      let(:user_cname) { User } 
      let(:role_cname) { Role }
      let(:dynamic_shortcuts) { true }
    end
  end

  context "using default Role and User class names without dynamic shortcuts", false do 
    it_behaves_like "Rolify module" do
      let(:user_cname) { User } 
      let(:role_cname) { Role }
      let(:dynamic_shortcuts) { false }
    end
  end

  context "using custom User and Role class names with dynamic shortcuts", true do 
    it_behaves_like "Rolify module" do
      let(:user_cname) { Customer }
      let(:role_cname) { Privilege }
      let(:dynamic_shortcuts) { true }
    end
  end

  context "using custom User and Role class names without dynamic shortcuts", false do 
    it_behaves_like "Rolify module" do
      let(:user_cname) { Customer }
      let(:role_cname) { Privilege }
      let(:dynamic_shortcuts) { false }
    end
  end
end
