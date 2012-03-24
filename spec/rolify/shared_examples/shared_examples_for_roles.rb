require "rolify/shared_contexts"
require "rolify/shared_examples/shared_examples_for_has_role_setter"
require "rolify/shared_examples/shared_examples_for_has_role_getter"
require "rolify/shared_examples/shared_examples_for_has_all_roles"
require "rolify/shared_examples/shared_examples_for_has_any_role"
require "rolify/shared_examples/shared_examples_for_has_no_role"


shared_examples_for Rolify::Role do
  before(:all) do
    reset_defaults
    Rolify.user_cname = user_cname
    Rolify.dynamic_shortcuts = false
    Rolify.user_cname.rolify :role_cname => role_cname
    Rolify.role_cname.destroy_all
    Forum.resourcify :role_cname => role_cname
    Group.resourcify :role_cname => role_cname
  end

  context "in a Instance level" do 
    before(:all) do
      admin = Rolify.user_cname.first
      admin.has_role "admin"
      admin.has_role "moderator", Forum.first
      admin
    end

    subject do
      Rolify.user_cname.first
    end

    it { should respond_to(:has_role).with(1).arguments }
    it { should respond_to(:has_role).with(2).arguments }

    it { should respond_to(:grant).with(1).arguments }
    it { should respond_to(:grant).with(2).arguments }

    it { should respond_to(:has_role?).with(1).arguments }
    it { should respond_to(:has_role?).with(2).arguments }

    it { should respond_to(:has_all_roles?) }
    it { should respond_to(:has_all_roles?) }

    it { should respond_to(:has_any_role?) }
    it { should respond_to(:has_any_role?) }

    it { should respond_to(:has_no_role).with(1).arguments }
    it { should respond_to(:has_no_role).with(2).arguments }

    it { should respond_to(:revoke).with(1).arguments }
    it { should respond_to(:revoke).with(2).arguments }

    it { should_not respond_to(:is_admin?) }
    it { should_not respond_to(:is_moderator_of?) }
  end

  describe "#has_role" do 
    it_should_behave_like "#has_role_examples", "String", :to_s
    it_should_behave_like "#has_role_examples", "Symbol", :to_sym
  end

  describe "#has_role?" do    
    it_should_behave_like "#has_role?_examples", "String", :to_s
    it_should_behave_like "#has_role?_examples", "Symbol", :to_sym
  end

  describe "#has_all_roles?" do
    it_should_behave_like "#has_all_roles?_examples", "String", :to_s
    it_should_behave_like "#has_all_roles?_examples", "Symbol", :to_sym
  end
  
  describe "#has_any_role?" do
    it_should_behave_like "#has_any_role?_examples", "String", :to_s
    it_should_behave_like "#has_any_role?_examples", "Symbol", :to_sym
  end
  
  describe "#has_no_role" do
    it_should_behave_like "#has_no_role_examples", "String", :to_s
    it_should_behave_like "#has_no_role_examples", "Symbol", :to_sym
  end
end