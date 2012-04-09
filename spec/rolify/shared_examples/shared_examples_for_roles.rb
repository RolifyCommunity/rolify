require "rolify/shared_contexts"
require "rolify/shared_examples/shared_examples_for_add_role"
require "rolify/shared_examples/shared_examples_for_has_role"
require "rolify/shared_examples/shared_examples_for_has_all_roles"
require "rolify/shared_examples/shared_examples_for_has_any_role"
require "rolify/shared_examples/shared_examples_for_remove_role"


shared_examples_for Rolify::Role do
  before(:all) do
    reset_defaults
    Rolify.dynamic_shortcuts = false
    user_class.rolify :role_cname => role_class.to_s
    role_class.destroy_all
    Forum.resourcify :role_cname => role_class.to_s
    Group.resourcify :role_cname => role_class.to_s
  end

  context "in the Instance level" do 
    before(:all) do
      admin = user_class.first
      admin.add_role :admin
      admin.add_role :moderator, Forum.first
    end

    subject { user_class.first }

    [ :has_role, :grant, :add_role ].each do |method_alias|
      it { should respond_to(method_alias.to_sym).with(1).arguments }
      it { should respond_to(method_alias.to_sym).with(2).arguments }
    end
    
    it { should respond_to(:has_role?).with(1).arguments }
    it { should respond_to(:has_role?).with(2).arguments }

    it { should respond_to(:has_all_roles?) }
    it { should respond_to(:has_all_roles?) }

    it { should respond_to(:has_any_role?) }
    it { should respond_to(:has_any_role?) }

    [ :has_no_role, :revoke, :remove_role ].each do |method_alias|
      it { should respond_to(method_alias.to_sym).with(1).arguments }
      it { should respond_to(method_alias.to_sym).with(2).arguments }
    end

    it { should_not respond_to(:is_admin?) }
    it { should_not respond_to(:is_moderator_of?) }
  end

  describe "#has_role" do 
    it_should_behave_like "#add_role_examples", "String", :to_s
    it_should_behave_like "#add_role_examples", "Symbol", :to_sym
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
    it_should_behave_like "#remove_role_examples", "String", :to_s
    it_should_behave_like "#remove_role_examples", "Symbol", :to_sym
  end

  context "on the Class level" do 
    before(:all) do
      role_class.destroy_all  
    end

    subject { User }
    
    let!(:admin_user) { provision_user(User.first, [ :admin ])}
    let!(:moderator_user) { provision_user(User.where(:login => "moderator").first, [ [ :moderator, Forum ] ])}
    let!(:visitor_user) { provision_user(User.last, [[ :visitor, Forum.last ]]) }
    
    
    describe ".with_role" do
      it { should respond_to(:with_role) }

      context "with a global role" do
        it { subject.with_role(:admin).should eq([ admin_user ]) }
        it { subject.with_role(:moderator).should be_empty }
        it { subject.with_role(:visitor).should be_empty }
      end
      
      context "with a class scoped role" do
        context "on Forum class" do
          it { subject.with_role(:admin, Forum).should eq([ admin_user ]) }
          it { subject.with_role(:moderator, Forum).should eq([ moderator_user]) }
          it { subject.with_role(:visitor, Forum).should be_empty }
        end
        
        context "on Group class" do
          it { subject.with_role(:admin, Group).should eq([ admin_user ]) }
          it { subject.with_role(:moderator, Group).should be_empty }
          it { subject.with_role(:visitor, Group).should be_empty }
        end
      end
      
      context "with an instance scoped role" do
        context "on Forum.first instance" do
          it { subject.with_role(:admin, Forum.first).should eq([ admin_user ]) }
          it { subject.with_role(:moderator, Forum.first).should eq([ moderator_user]) }
          it { subject.with_role(:visitor, Forum.first).should be_empty }
        end
        
        context "on Forum.last instance" do
          it { subject.with_role(:admin, Forum.last).should eq([ admin_user ]) }
          it { subject.with_role(:moderator, Forum.last).should eq([ moderator_user]) }
          it { subject.with_role(:visitor, Forum.last).should eq([ visitor_user ]) }
        end
        
        context "on Group.first instance" do
          it { subject.with_role(:admin, Group.first).should eq([ admin_user ]) }
          it { subject.with_role(:moderator, Group.first).should be_empty }
          it { subject.with_role(:visitor, Group.first).should be_empty }
        end
      end
    end

    describe ".with_all_roles" do

      it { should respond_to(:with_all_roles) }

    end

    describe ".with_any_role" do

      it { should respond_to(:with_any_role) }

    end
  end
end