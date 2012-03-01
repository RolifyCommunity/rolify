require "spec_helper"

describe Rolify::Resource do
  before(:all) do
    @admin = Rolify.user_cname.first
    @forum_role = @admin.has_role("forum", Forum.first)
    @godfather_role = @admin.has_role("godfather", Forum)
    @group_role = @admin.has_role("group", Group.last)
    @tourist = Rolify.user_cname.last
    @tourist_role = @tourist.has_role("forum", Forum.last)
    @sneaky_role = @tourist.has_role("group", Forum.first)
  end

  it "should respond to roles" do
    Forum.first.should respond_to(:roles)
    Forum.last.should respond_to(:roles)
  end

  it "should respond to with_roles" do
    Forum.should respond_to(:find_roles).with(1).arguments
    Forum.should respond_to(:find_roles).with(2).arguments
    Group.should respond_to(:find_roles).with(1).arguments
    Group.should respond_to(:find_roles).with(2).arguments
  end

  it "should get all roles binded to an instance resource" do
    Forum.first.applied_roles.should include(@forum_role, @godfather_role, @sneaky_role)
    Group.last.applied_roles.should include(@group_role)
  end

  it "should not get roles binded to another instance resource" do
    Forum.first.roles.should_not include(@groupe_role, @tourist_role)
    Group.last.roles.should_not include(@forum_role, @godfather_role, @sneaky_role, @tourist_role)
  end

  it "should get all roles binded to a class resource" do
    Forum.find_roles.should include(@forum_role, @godfather_role, @tourist_role, @sneaky_role)
    Forum.find_roles(:any, :any).should include(@forum_role, @godfather_role, @tourist_role, @sneaky_role)
    Forum.find_roles.should_not include(@group_role)
    Forum.find_roles(:any, :any).should_not include(@group_role)
    Group.find_roles.should include(@group_role)
    Group.find_roles(:any, :any).should include(@group_role)
    Group.find_roles.should_not include(@forum_role, @godfather_role, @tourist_role, @sneaky_role)
    Group.find_roles(:any, :any).should_not include(@forum_role, @godfather_role, @tourist_role, @sneaky_role)
  end

  it "should get all roles binded to a class resource and a specific role" do
    Forum.find_roles("forum").should include(@tourist_role, @forum_role)
    Forum.find_roles("forum", :any).should include(@tourist_role, @forum_role)
    Forum.find_roles("forum").should_not include(@group_role, @sneaky_role, @godfather_role)
    Forum.find_roles("forum", :any).should_not include(@group_role, @sneaky_role, @godfather_role)
    Group.find_roles("group").should include(@group_role)
    Group.find_roles("group").should_not include(@tourist_role, @forum_role, @godfather_role, @sneaky_role)
  end

  it "should get all roles binded to a class resource and a specific role of a specific user" do
    Forum.find_roles("forum", @admin).should include(@forum_role)
    Forum.find_roles("forum", @admin).should_not include(@tourist_role)
    Forum.find_roles("forum", @admin).should_not include(@group_role)
    Forum.find_roles("forum", @admin).should_not include(@sneaky_role)
  end

  it "should get all roles binded to a class resource and any role of a specific user" do
    Forum.find_roles(:any, @admin).should include(@forum_role, @godfather_role)
    Forum.find_roles(:any, @admin).should_not include(@tourist_role)
    Forum.find_roles(:any, @admin).should_not include(@group_role)
    Forum.find_roles(:any, @admin).should_not include(@sneaky_role)
  end

  it "should get all resources binded to a specific role" do
    Forum.with_role("forum").should include(Forum.first, Forum.last)
    Forum.with_role("godfather").should == Forum.all
    Group.with_role("group").should include(Group.last)
  end

  it "should get all resources binded to a specific role and a specific user having one this role" do
    Forum.with_role("forum", @admin).should include(Forum.first)
    Forum.with_role("forum", @tourist).should include(Forum.last)
    Forum.with_role("godfather", @admin).should == Forum.all
    Forum.with_role("godfather", @tourist).should be_empty
    Group.with_role("group", @admin).should include(Group.last)
    Group.with_role("group", @admin).should_not include(Group.first)
    Forum.with_role("group", @tourist).should include(Forum.first)
    Forum.with_role("group", @tourist).should_not include(Forum.last)
  end
end