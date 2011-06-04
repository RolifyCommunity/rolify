require "spec_helper"

describe "Rolify::Role" do

  context "with a global role" do 
    before(:all) do
      @admin = User.first
      @admin.has_role "admin"
    end
    
    it "should set a global role" do
      expect { @admin.has_role "superadmin" }.to change{ Role.count }.by(1)
      superadmin = Role.last
      superadmin.name.should eq("superadmin")
      superadmin.resource.should be(nil)
    end
    
    it "should not create another role if already existing" do
      expect { @admin.has_role "admin" }.not_to change{ Role.count }
      expect { @admin.has_role "admin" }.not_to change{ @admin.roles.size }
    end
    
    it "should get a global role" do
      @admin.has_role?("admin").should be(true)
    end
    
    it "should get any resource request" do
      @admin.has_role?("admin", Forum.first).should be(true)
    end
    
    it "should not get another global role" do
      Role.create(:name => "global")
      @admin.has_role?("global").should be(false)
    end
    
    it "should not get a scoped role" do
      @admin.has_role?("moderator", Forum.last).should be(false)
    end
    
    it "should not get inexisting role" do
      @admin.has_role?("dummy").should be(false)
      @admin.has_role?("dumber", Forum.first).should be(false)
    end
  end
  
  context "with a scoped role" do
    before(:all) do
      @moderator = User.last
      @moderator.has_role "moderator", Forum.first
    end
      
    it "should set a scoped role" do
      @moderator
    end
    
    it "should not create another role if already existing" do
      expect { @moderator.has_role "moderator", Forum.first }.not_to change{ Role.count }
      expect { @moderator.has_role "moderator" , Forum.first }.not_to change{ @moderator.roles.size }
    end
    
    it "should get a scoped role" do
      expect { @moderator.has_role "supermodo", Forum.last }.to change{ Role.count }.by(1)
      supermodo = Role.last
      supermodo.name.should eq("supermodo")
      supermodo.resource.should eq(Forum.last)
    end
    
    it "should not get a global role" do
      @moderator.has_role?("admin").should be(false)
    end
    
    it "should not get the same role on another resource" do
      Role.create(:name => "moderator", :resource => Forum.last)
      @moderator.has_role?("moderator", Forum.last).should be(false)
    end
    
    it "should not get the another role on the same resource" do
      Role.create(:name => "tourist", :resource => Forum.first)
      @moderator.has_role?("tourist", Forum.first).should be(false)
    end
    
    it "should not get inexisting role" do
      @moderator.has_role?("dummy", Forum.last).should be(false)
      @moderator.has_role?("dumber").should be(false)
    end
  end
end