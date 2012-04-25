require "rolify/shared_contexts"

shared_examples_for "Role.scopes" do |param_name, param_method|
  before(:all) do
    role_class.destroy_all
  end
  
  subject { user_class.first }
  
  describe ".global" do 
    let!(:admin_role) { subject.add_role :admin }
    let!(:staff_role) { subject.add_role :staff }
     
    it { subject.roles.global.should == [ admin_role, staff_role ] }
  end
  
  describe ".class_scoped" do
    let!(:manager_role) { subject.add_role :manager, Group }
    let!(:moderator_role) { subject.add_role :moderator, Forum }
    
    it { subject.roles.class_scoped.should == [ manager_role, moderator_role ] }
  end
  
  describe ".instance_scoped" do
    let!(:visitor_role) { subject.add_role :visitor, Forum.first }
    let!(:anonymous_role) { subject.add_role :anonymous, Group.last }
    
    it { subject.roles.instance_scoped.should == [ visitor_role, anonymous_role ]}
  end
end