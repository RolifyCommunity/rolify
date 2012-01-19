require "spec_helper"

shared_examples_for "Rolify module" do |dynamic|
  before(:all) do
    Rolify.user_cname = user_cname
    @forum = forum
    @group = group
    Rolify.dynamic_shortcuts = dynamic_shortcuts
    Rolify.user_cname.rolify :role_cname => role_cname
    Rolify.role_cname.destroy_all
  end
  
  context "in a Instance level" do 
    before(:all) do
      @admin = Rolify.user_cname.first
      @admin.has_role "admin"
      @admin.has_role "moderator", @forum.first
    end

    it "should respond to has_role method" do 
      @admin.should respond_to(:has_role).with(1).arguments
      @admin.should respond_to(:has_role).with(2).arguments
    end
    
    it "should respond to grant method" do 
      @admin.should respond_to(:grant).with(1).arguments
      @admin.should respond_to(:grant).with(2).arguments
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
    
    it "should respond to revoke method" do
      @admin.should respond_to(:revoke).with(1).arguments
      @admin.should respond_to(:revoke).with(2).arguments
    end

    it "should respond to dynamic methods", :if => dynamic do
      @admin.should respond_to(:is_admin?).with(0).arguments
      @admin.should respond_to(:is_moderator_of?).with(1).arguments
    end

    it "should not respond to any unknown methods", :if => dynamic do
      @admin.should_not respond_to(:is_god?)
    end

    it "should create a new dynamic method if role exists in database", :if => dynamic do 
      other_guy = Rolify.user_cname.last
      other_guy.has_role "superman"
      @admin.should respond_to(:is_superman?).with(0).arguments
      other_guy.has_role("batman", @forum.first)
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
      @admin.has_role "moderator", @forum.first
      @admin.has_role "moderator", @forum.where(:name => "forum 2").first
      @admin.has_role "manager", @group
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
    end

    it "should get any resource request" do
      @admin.has_role?("admin", @forum.first).should be(true)
      @admin.has_role?("admin", @forum).should be(true)
      @admin.has_role?("admin", :any).should be(true)
    end

    it "should not get another global role" do
      Rolify.role_cname.create(:name => "global")
      @admin.has_role?("global").should be(false)
      @admin.has_role?("global", :any).should be(false)
    end

    it "should not get an instance scoped role" do
      @admin.has_role?("moderator", @forum.last).should be(false)
    end

    it "should not get a class scoped role" do
      @admin.has_role?("manager", @forum).should be(false)
    end

    it "should not get inexisting role" do
      @admin.has_role?("dummy").should be(false)
      @admin.has_role?("dumber", @forum.first).should be(false)
    end

    it "should check if user has all of a global roles set" do
      @admin.has_all_roles?("staff").should be(true)
      @admin.has_all_roles?("admin", "staff").should be(true)
      @admin.has_all_roles?("admin", "dummy").should be(false)
      @admin.has_all_roles?("dummy", "dumber").should be(false)
      @admin.has_all_roles?({ :name => "admin", :resource => @forum }, { :name => "admin", :resource => @group }).should be(true)
      @admin.has_all_roles?({ :name => "admin", :resource => :any }, { :name => "admin", :resource => @group }).should be(true)
      @admin.has_all_roles?({ :name => "admin", :resource => @forum }, { :name => "staff", :resource => @group.last }).should be(true)
      @admin.has_all_roles?({ :name => "admin", :resource => @forum.first }, { :name => "admin", :resource => @forum.last }).should be(true)
      @admin.has_all_roles?({ :name => "admin", :resource => @forum.first }, { :name => "dummy", :resource => @forum.last }).should be(false)
      @admin.has_all_roles?({ :name => "admin", :resource => @forum.first }, { :name => "dummy", :resource => :any }).should be(false)
    end

    it "should check if user has any of a global roles set" do
      @admin.has_any_role?("staff").should be(true)
      @admin.has_any_role?("admin", "staff").should be(true)
      @admin.has_any_role?("admin", "moderator").should be(true)
      @admin.has_any_role?("dummy", "dumber").should be(false)
      @admin.has_any_role?({ :name => "admin", :resource => @forum }, { :name => "admin", :resource => @group }).should be(true)
      @admin.has_any_role?({ :name => "admin", :resource => :any }, { :name => "admin", :resource => @group }).should be(true)
      @admin.has_any_role?({ :name => "admin", :resource => @forum }, { :name => "staff", :resource => @group.last }).should be(true)
      @admin.has_any_role?({ :name => "admin", :resource => @forum.first }, { :name => "admin", :resource => @forum.last }).should be(true)
      @admin.has_any_role?({ :name => "admin", :resource => @forum.first }, { :name => "dummy", :resource => @forum.last }).should be(true)
      @admin.has_any_role?({ :name => "admin", :resource => @forum.first }, { :name => "dummy", :resource => :any }).should be(true)
    end

    it "should remove a global role of a user" do 
      expect { @admin.has_no_role("admin") }.to change{ @admin.roles.size }.by(-1)
      @admin.has_role?("admin").should be(false)
      @admin.has_role?("staff").should be(true)
      @admin.has_role?("moderator", @forum.first).should be(true)
      @admin.has_role?("manager", @group).should be(true)
    end

    it "should remove a class scoped role of a user" do
      expect { @admin.has_no_role("manager") }.to change{ @admin.roles.size }.by(-1)
      @admin.has_role?("staff").should be(true)
      @admin.has_role?("moderator", @forum.first).should be(true)
      @admin.has_role?("manager", @group).should be(false)
    end
    
    it "should remove two instance scoped roles of a user" do
      expect { @admin.has_no_role("moderator") }.to change{ @admin.roles.size }.by(-2)
      @admin.has_role?("staff").should be(true)
      @admin.has_role?("moderator", @forum.first).should be(false)
      @admin.has_role?("moderator", @forum.where(:name => "forum 2").first).should be(false)
      @admin.has_role?("manager", @group).should be(true)
    end

    it "should not remove another global role" do 
      expect { @admin.has_no_role("global") }.not_to change{ @admin.roles.size }
    end
  end

  context "with an instance scoped role" do
    before do
      @moderator = Rolify.user_cname.where(:login => "moderator").first
      @moderator.has_role "moderator", @forum.first
      @moderator.has_role "soldier"
      ActiveRecord::Base.logger = nil
    end

    it "should set an instance scoped role" do
      expect { @moderator.has_role "visitor", @forum.last }.to change{ Rolify.role_cname.count }.by(1)
      visitor = Rolify.role_cname.last
      visitor.name.should eq("visitor")
      visitor.resource.should eq(@forum.last)
    end

    it "should not create another role if already existing" do
      expect { @moderator.has_role "moderator", @forum.first }.not_to change{ Rolify.role_cname.count }
      expect { @moderator.has_role "moderator", @forum.first }.not_to change{ @moderator.roles.size }
    end

    it "should get an instance scoped role" do
      @moderator.has_role?("moderator", @forum.first).should be(true)
    end

    it "should get any of instance scoped role" do
      @moderator.has_role?("moderator", :any).should be(true)
    end

    it "should not get an instance scoped role when asking for a global" do
      @moderator.has_role?("moderator").should be(false)
    end

    it "should not get an instance scoped role when asking for a class scoped" do 
      @moderator.has_role?("moderator", @forum).should be(false)
    end

    it "should be able to use dynamic shortcut", :if => dynamic do
      @moderator.is_moderator?.should be(false)
      @moderator.is_moderator_of?(@forum.first).should be(true)
      @moderator.is_moderator_of?(@forum.last).should be(false)
      @moderator.is_moderator_of?(@forum).should be(false)
    end

    it "should not get a global role" do
      @moderator.has_role?("admin").should be(false)
    end

    it "should not get the same role on another resource" do
      Rolify.role_cname.create(:name => "moderator", :resource => @forum.last)
      @moderator.has_role?("moderator", @forum.last).should be(false)
    end

    it "should not get the another role on the same resource" do
      Rolify.role_cname.create(:name => "tourist", :resource => @forum.first)
      @moderator.has_role?("tourist", @forum.first).should be(false)
      @moderator.has_role?("tourist", :any).should be(false)
    end

    it "should not get inexisting role" do
      @moderator.has_role?("dummy", @forum.last).should be(false)
      @moderator.has_role?("dumber").should be(false)
    end

    it "should check if user has all of a scoped roles set" do
      @moderator.has_role "visitor", @forum.last
      @moderator.has_all_roles?({ :name => "visitor", :resource => @forum.last }).should be(true)
      @moderator.has_all_roles?({ :name => "moderator", :resource => :any }, { :name => "visitor", :resource => @forum.last }).should be(true)
      @moderator.has_all_roles?({ :name => "moderator", :resource => :any }, { :name => "visitor", :resource => :any }).should be(true)
      @moderator.has_all_roles?({ :name => "moderator", :resource => :any }, { :name => "visitor", :resource => :any }).should be(true)
      @moderator.has_all_roles?({ :name => "moderator", :resource => :any }, { :name => "visitor", :resource => @forum }).should be(false)
      @moderator.has_all_roles?({ :name => "moderator", :resource => @forum.first }, { :name => "visitor", :resource => @forum.last }).should be(true)
      @moderator.has_all_roles?({ :name => "moderator", :resource => @forum.first }, { :name => "moderator", :resource => @forum.last }).should be(false)
      @moderator.has_all_roles?({ :name => "moderator", :resource => @forum.first }, { :name => "dummy", :resource => @forum.last }).should be(false)
      @moderator.has_all_roles?({ :name => "dummy", :resource => @forum.first }, { :name => "dumber", :resource => @forum.last }).should be(false)
    end

    it "should check if user has any of a scoped roles set" do
      @moderator.has_role "visitor", @forum.last
      @moderator.has_any_role?({ :name => "visitor", :resource => @forum.last }).should be(true)
      @moderator.has_any_role?({ :name => "moderator", :resource => @forum.first }, { :name => "visitor", :resource => @forum.last }).should be(true)
      @moderator.has_any_role?({ :name => "moderator", :resource => :any }, { :name => "visitor", :resource => @forum.last }).should be(true)
      @moderator.has_any_role?({ :name => "moderator", :resource => :any }, { :name => "visitor", :resource => :any}).should be(true)
      @moderator.has_any_role?({ :name => "moderator", :resource => @forum }, { :name => "visitor", :resource => :any }).should be(true)
      @moderator.has_any_role?({ :name => "moderator", :resource => @forum.first }, { :name => "moderator", :resource => @forum.last }).should be(true)
      @moderator.has_any_role?({ :name => "moderator", :resource => @forum.first }, { :name => "dummy", :resource => @forum.last }).should be(true)
      @moderator.has_any_role?({ :name => "dummy", :resource => @forum.first }, { :name => "dumber", :resource => @forum.last }).should be(false)
    end

    it "should not remove a global role of a user" do 
      expect { @moderator.has_no_role("soldier", @forum.first) }.not_to change{ @moderator.roles.size }
    end

    it "should remove a scoped role of a user" do 
      expect { @moderator.has_no_role("moderator", @forum.first) }.to change{ @moderator.roles.size }.by(-1)
      @moderator.has_role?("moderator", @forum.first).should be(false)
      @moderator.has_role?("soldier").should be(true)
    end

    it "should not remove another scoped role" do
      expect { @moderator.has_no_role("visitor", @forum.first) }.not_to change{ @moderator.roles.size }
    end
  end

  context "with a class scoped role" do
    before do
      @manager = Rolify.user_cname.where(:login => "god").first
      @manager.has_role "manager", @forum
      @manager.has_role "moderator", @forum.first
      @manager.has_role "moderator", @forum.last
      @manager.has_role "warrior"
    end

    it "should set a class scoped role" do
      expect { @manager.has_role "player", @forum }.to change{ Rolify.role_cname.count }.by(1)
      player = Rolify.role_cname.last
      player.name.should eq("player")
      player.resource_type.should eq(@forum.to_s)
    end

    it "should not create another role if already existing" do
      expect { @manager.has_role "manager", @forum }.not_to change{ Rolify.role_cname.count }
      expect { @manager.has_role "manager", @forum }.not_to change{ @manager.roles.size }
    end

    it "should get a class scoped role" do
      @manager.has_role?("manager", @forum).should be(true)
      @manager.has_role?("manager", @forum.first).should be(true)
    end

    it "should get any of class scoped role" do
      @manager.has_role?("manager", :any).should be(true)
    end

    it "should not get a scoped role when asking for a global" do
      @manager.has_role?("manager").should be(false)
    end

    it "should be able to use dynamic shortcut", :if => dynamic do
      @manager.is_manager?.should be(false)
      @manager.is_manager_of?(@forum.first).should be(true)
      @manager.is_manager_of?(@forum.last).should be(true)
      @manager.is_manager_of?(@forum).should be(true)
      @manager.is_manager_of?(@group).should be(false)
    end

    it "should not get a global role" do
      @manager.has_role?("admin").should be(false)
    end

    it "should not get the same role on another resource" do
      Rolify.role_cname.create(:name => "manager", :resource_type => "@group")
      @manager.has_role?("manager", @group).should be(false)
    end

    it "should not get the another role on the same resource" do
      Rolify.role_cname.create(:name => "member", :resource_type => "@forum")
      @manager.has_role?("member", @forum).should be(false)
      @manager.has_role?("member", :any).should be(false)
    end

    it "should not get inexisting role" do
      @manager.has_role?("dummy", @forum).should be(false)
      @manager.has_role?("dumber").should be(false)
    end

    it "should check if user has all of a scoped roles set" do
      @manager.has_role "player", @forum
      @manager.has_all_roles?({ :name => "player", :resource => @forum }).should be(true)
      @manager.has_all_roles?({ :name => "manager", :resource => @forum }, { :name => "player", :resource => @forum }).should be(true)
      @manager.has_all_roles?({ :name => "manager", :resource => :any }, { :name => "player", :resource => @forum }).should be(true)
      @manager.has_all_roles?({ :name => "manager", :resource => :any }, { :name => "player", :resource => :any }).should be(true)
      @manager.has_all_roles?({ :name => "manager", :resource => @forum }, { :name => "dummy", :resource => @forum }).should be(false)
      @manager.has_all_roles?({ :name => "manager", :resource => @forum }, { :name => "dummy", :resource => :any }).should be(false)
      @manager.has_all_roles?({ :name => "dummy", :resource => @forum }, { :name => "dumber", :resource => @group }).should be(false)
      @manager.has_all_roles?({ :name => "manager", :resource => @forum.first }, { :name => "manager", :resource => @forum.last }).should be(true)
      @manager.has_all_roles?({ :name => "manager", :resource => @group }, { :name => "moderator", :resource => @forum.first }).should be(false)
      @manager.has_all_roles?({ :name => "manager", :resource => @forum.first }, { :name => "moderator", :resource => @forum }).should be(false)
      @manager.has_all_roles?({ :name => "manager", :resource => @forum.last }, { :name => "warrior", :resource => @forum.last }).should be(true)
    end

    it "should check if user has any of a scoped roles set" do
      @manager.has_any_role?({ :name => "player", :resource => @forum }).should be(true)
      @manager.has_any_role?({ :name => "manager", :resource => @forum }, { :name => "player", :resource => @forum }).should be(true)
      @manager.has_any_role?({ :name => "manager", :resource => @forum }, { :name => "player", :resource => :any }).should be(true)
      @manager.has_any_role?({ :name => "manager", :resource => :any }, { :name => "player", :resource => :any }).should be(true)
      @manager.has_any_role?({ :name => "manager", :resource => @forum }, { :name => "dummy", :resource => @forum }).should be(true)
      @manager.has_any_role?({ :name => "manager", :resource => @forum }, { :name => "dummy", :resource => :any }).should be(true)
      @manager.has_any_role?({ :name => "dummy", :resource => @forum }, { :name => "dumber", :resource => @group }).should be(false)
      @manager.has_any_role?({ :name => "manager", :resource => @forum.first }, { :name => "manager", :resource => @forum.last }).should be(true)
      @manager.has_any_role?({ :name => "manager", :resource => @group }, { :name => "moderator", :resource => @forum.first }).should be(true)
      @manager.has_any_role?({ :name => "manager", :resource => @forum.first }, { :name => "moderator", :resource => @forum }).should be(true)
      @manager.has_any_role?({ :name => "manager", :resource => @forum.last }, { :name => "warrior", :resource => @forum.last }).should be(true)
    end

    it "should not remove a global role of a user" do 
      expect { @manager.has_no_role("warrior", @forum) }.not_to change{ @manager.roles.size }
    end

    it "should remove a class scoped role of a user" do 
      expect { @manager.has_no_role("manager", @forum) }.to change{ @manager.roles.size }.by(-1)
      @manager.has_role?("manager", @forum).should be(false)
      @manager.has_role?("moderator", @forum.first).should be(true)
      @manager.has_role?("moderator", @forum.last).should be(true)
      @manager.has_role?("warrior").should be(true)
    end
    
    it "should remove two instance scoped roles of a user" do 
      expect { @manager.has_no_role("moderator", @forum) }.to change{ @manager.roles.size }.by(-2)
      @manager.has_role?("manager", @forum).should be(true)
      @manager.has_role?("moderator", @forum.first).should be(false)
      @manager.has_role?("moderator", @forum.last).should be(false)
      @manager.has_role?("warrior").should be(true)
    end

    it "should not remove another scoped role" do
      expect { @manager.has_no_role("visitor", @forum.first) }.not_to change{ @manager.roles.size }
    end
  end

  context "with different roles" do 
    before do 
      @user = Rolify.user_cname.where(:login => "zombie").first
      @user.has_role "admin"
      @user.has_role "anonymous"
      @user.has_role "moderator", @forum.first
      @user.has_role "visitor", @forum.last
      @user.has_role "manager", @forum
      @user.has_role "leader", @group
      Rolify.role_cname.create :name => "manager", :resource => @forum.first
      Rolify.role_cname.create :name => "manager", :resource => @forum.where(:name => "forum 2").first
      Rolify.role_cname.create :name => "manager", :resource => @forum.where(:name => "forum 3").first
    end

    it "should get a global role" do
      @user.has_role?("admin").should be(true)
      @user.has_role?("anonymous").should be(true)
    end

    it "should get an instance scoped role" do
      @user.has_role?("moderator", @forum.first).should be(true)
      @user.has_role?("visitor", @forum.last).should be(true)
    end

    it "should get an class scoped role" do
      @user.has_role?("manager", @forum).should be(true)
      @user.has_role?("leader", @group).should be(true)
    end

    it "should check if user has all of a mix of global and scoped roles set" do
      @user.has_all_roles?("admin", { :name => "moderator", :resource => @forum.first }, { :name => "manager", :resource => @forum }).should be(true)
      @user.has_all_roles?("admin", { :name => "moderator", :resource => @forum.last }, { :name => "manager", :resource => @forum }).should be(false)
      @user.has_all_roles?("admin", { :name => "moderator", :resource => :any }, { :name => "manager", :resource => @forum }).should be(true)
      @user.has_all_roles?("admin", { :name => "moderator", :resource => :any }, { :name => "manager", :resource => :any }).should be(true)
      @user.has_all_roles?("admin", { :name => "moderator", :resource => @forum.first }, { :name => "manager", :resource => @group }).should be(false)
      @user.has_all_roles?("admin", { :name => "moderator", :resource => @forum.first }, { :name => "manager", :resource => @group.first }).should be(false)
      @user.has_all_roles?({ :name => "admin", :resource => @forum }, { :name => "moderator", :resource => @forum.first }, { :name => "manager", :resource => @forum }).should be(true)
      @user.has_all_roles?({ :name => "admin", :resource => @forum.first }, { :name => "moderator", :resource => @forum.first }, { :name => "manager", :resource => @forum }).should be(true)
      @user.has_all_roles?("admin", { :name => "moderator", :resource => @forum.first }, { :name => "manager", :resource => @forum.first }).should be(true)
      @user.has_all_roles?("dummy", { :name => "dumber", :resource => @forum.last }, { :name => "dumberer", :resource => @forum }).should be(false)
      @user.has_all_roles?("admin", "dummy", { :name => "dumber", :resource => @forum.last }, { :name => "dumberer", :resource => @forum }).should be(false)
      @user.has_all_roles?({ :name => "manager", :resource => @forum.last }, "dummy", { :name => "dumber", :resource => @forum.last }, { :name => "dumberer", :resource => @forum }).should be(false)
      @user.has_all_roles?("admin", { :name => "dumber", :resource => @forum.last }, { :name => "manager", :resource => @forum.last }).should be(false)
      @user.has_all_roles?({ :name => "admin", :resource => @forum.first }, { :name => "moderator", :resource => @forum.first }, { :name => "manager", :resource => @forum.last }).should be(true)
      @user.has_all_roles?({ :name => "admin", :resource => @forum.first }, { :name => "moderator", :resource => :any }, { :name => "manager", :resource => @forum.last }).should be(true)
    end

    it "should check if user has any of a mix of global and scoped roles set" do
      @user.has_any_role?("admin", { :name => "moderator", :resource => @forum.first }, { :name => "manager", :resource => @forum }).should be(true)
      @user.has_any_role?("admin", { :name => "moderator", :resource => :any }, { :name => "manager", :resource => @forum }).should be(true)
      @user.has_any_role?("admin", { :name => "moderator", :resource => @forum.first }, { :name => "manager", :resource => :any }).should be(true)
      @user.has_any_role?("admin", { :name => "moderator", :resource => :any }, { :name => "manager", :resource => :any }).should be(true)
      @user.has_any_role?("admin", { :name => "moderator", :resource => @forum.last }, { :name => "manager", :resource => @forum }).should be(true)
      @user.has_any_role?("admin", { :name => "moderator", :resource => @forum.last }, { :name => "manager", :resource => @group }).should be(true)
      @user.has_any_role?("admin", { :name => "moderator", :resource => @forum.last }, { :name => "manager", :resource => @group.first }).should be(true)
      @user.has_any_role?({ :name => "admin", :resource => @forum }, { :name => "moderator", :resource => @forum.last }, { :name => "manager", :resource => @forum }).should be(true)
      @user.has_any_role?({ :name => "admin", :resource => @forum.first }, { :name => "moderator", :resource => @forum.last }, { :name => "manager", :resource => @forum }).should be(true)
      @user.has_any_role?("admin", { :name => "moderator", :resource => @forum.last }, { :name => "manager", :resource => @forum.first }).should be(true)
      @user.has_any_role?("dummy", { :name => "dumber", :resource => @forum.last }, { :name => "dumberer", :resource => @forum }).should be(false)
      @user.has_any_role?({ :name => "manager", :resource => @forum.last }, "dummy", { :name => "dumber", :resource => @forum.last }, { :name => "dumberer", :resource => @forum }).should be(true)
    end
  end

end

describe Rolify do
  context "using default Role and User class names with dynamic shortcuts", true do 
    it_behaves_like "Rolify module" do
      let(:user_cname) { "User" } 
      let(:role_cname) { "Role" }
      let(:dynamic_shortcuts) { true }
      let(:forum) { Forum }
      let(:group) { Group }
    end
  end

  context "using default Role and User class names without dynamic shortcuts", false do 
    it_behaves_like "Rolify module" do
      let(:user_cname) { "User" } 
      let(:role_cname) { "Role" }
      let(:dynamic_shortcuts) { false }
      let(:forum) { Forum }
      let(:group) { Group }
    end
  end

  context "using custom User and Role class names with dynamic shortcuts", true do 
    it_behaves_like "Rolify module" do
      let(:user_cname) { "Customer" }
      let(:role_cname) { "Privilege" }
      let(:dynamic_shortcuts) { true }
      let(:forum) { Forum }
      let(:group) { Group }
    end
  end

  context "using custom User and Role class names without dynamic shortcuts", false do 
    it_behaves_like "Rolify module" do
      let(:user_cname) { "Customer" }
      let(:role_cname) { "Privilege" }
      let(:dynamic_shortcuts) { false }
      let(:forum) { Forum }
      let(:group) { Group }
    end
  end
end
