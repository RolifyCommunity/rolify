require "spec_helper"

describe Rolify::Resource do
  before(:all) do
    reset_defaults
    User.rolify :role_cname => "Role"
    Forum.resourcify :role_cname => "Role"
    Group.resourcify :role_cname => "Role"
  end

  # Users
  let(:admin)   { User.first }
  let(:tourist) { User.last }
  
  # roles
  let!(:forum_role)      { admin.add_role(:forum, Forum.first) }
  let!(:godfather_role)  { admin.add_role(:godfather, Forum) }
  let!(:group_role)      { admin.add_role(:group, Group.last) }
  let!(:grouper_role)    { admin.add_role(:grouper, Group.first) }
  let!(:tourist_role)    { tourist.add_role(:forum, Forum.last) }
  let!(:sneaky_role)     { tourist.add_role(:group, Forum.first) }

  describe ".with_roles" do
    subject { Group }

    it { should respond_to(:find_roles).with(1).arguments }
    it { should respond_to(:find_roles).with(2).arguments }

    context "with a role name as argument" do 
      context "on the Forum class" do 
        subject { Forum }

        it "should include Forum instances with forum role" do 
          subject.with_role(:forum).should include(Forum.first, Forum.last)
        end
        it "should include Forum instances with godfather role" do 
          subject.with_role(:godfather).should eq(Forum.all)
        end
      end

      context "on the Group class" do 
        subject { Group }

        it "should include Group instances with group role" do
          subject.with_role(:group).should include(Group.last)
        end
      end

    end

    context "with an array of role names as argument" do 
      context "on the Group class" do 
        subject { Group }
        it "should include Group instances with both group and grouper roles" do 
          subject.with_roles([:group, :grouper]).should include(Group.first, Group.last)
        end
      end
    end

    context "with a role name and a user as arguments" do
      context "on the Forum class" do 
        subject { Forum }

        it "should get all Forum instances binded to the forum role and the admin user" do
          subject.with_role(:forum, admin).should include(Forum.first)
        end

        it "should get all Forum instances binded to the forum role and the tourist user" do
          subject.with_role(:forum, tourist).should include(Forum.last)
        end

        it "should get all Forum instances binded to the godfather role and the admin user" do
          subject.with_role(:godfather, admin).should == Forum.all
        end

        it "should get all Forum instances binded to the godfather role and the tourist user" do
          subject.with_role(:godfather, tourist).should be_empty
        end

        it "should get Forum instances binded to the group role and the tourist user" do
          subject.with_role(:group, tourist).should include(Forum.first)
        end

        it "should not get Forum instances not binded to the group role and the tourist user" do
          subject.with_role(:group, tourist).should_not include(Forum.last)
        end
      end

      context "on the Group class" do 
        subject { Group }

        it "should get all resources binded to the group role and the admin user" do
          subject.with_role(:group, admin).should include(Group.last)
        end

        it "should not get resources not binded to the group role and the admin user" do
          subject.with_role(:group, admin).should_not include(Group.first)
        end
      end
    end

    context "with an array of role names and a user as arguments" do
      context "on the Forum class" do 
        subject { Forum }

        it "should get Forum instances binded to the forum and group roles and the tourist user" do
          subject.with_roles([:forum, :group], tourist).should include(Forum.first, Forum.last)
        end

      end

      context "on the Group class" do 
        subject { Group }

        it "should get Group instances binded to the group and grouper roles and the admin user" do
          subject.with_roles([:group, :grouper], admin).should include(Group.first, Group.last)
        end

      end
    end

  end

  describe ".find_role" do

    context "without using a role name parameter" do 
      
      context "on the Forum class" do
        subject { Forum }

        it "should get all roles binded to a Forum class or instance" do
          subject.find_roles.should include(forum_role, godfather_role, tourist_role, sneaky_role)
        end

        it "should not get roles not binded to a Forum class or instance" do
          subject.find_roles.should_not include(group_role)
        end

        context "using :any parameter" do
          it "should get all roles binded to any Forum class or instance" do
            subject.find_roles(:any, :any).should include(forum_role, godfather_role, tourist_role, sneaky_role)
          end

          it "should not get roles not binded to a Forum class or instance" do
            subject.find_roles(:any, :any).should_not include(group_role)
          end
        end
      end

      context "on the Group class" do
        subject { Group }
        
        it "should get all roles binded to a Group class or instance" do
          subject.find_roles.should include(group_role)
        end

        it "should not get roles not binded to a Group class or instance" do
          subject.find_roles.should_not include(forum_role, godfather_role, tourist_role, sneaky_role)
        end

        context "using :any parameter" do
          it "should get all roles binded to Group class or instance" do
            subject.find_roles(:any, :any).should include(group_role)
          end

          it "should not get roles not binded to a Group class or instance" do
            subject.find_roles(:any, :any).should_not include(forum_role, godfather_role, tourist_role, sneaky_role)
          end
        end
      end
    end

    context "using a role name parameter" do 
      context "on the Forum class" do
        subject { Forum }

        context "without using a user parameter" do
          it "should get all roles binded to a Forum class or instance and forum role name" do
            subject.find_roles(:forum).should include(forum_role, tourist_role)
          end

          it "should not get roles not binded to a Forum class or instance and forum role name" do
            subject.find_roles(:forum).should_not include(godfather_role, sneaky_role, group_role)
          end
        end

        context "using a user parameter" do
          it "should get all roles binded to any resource" do
            subject.find_roles(:forum, admin).should include(forum_role)
          end

          it "should not get roles not binded to the admin user and forum role name" do
            subject.find_roles(:forum, admin).should_not include(godfather_role, tourist_role, sneaky_role, group_role)
          end
        end

        context "using :any parameter" do
          it "should get all roles binded to any resource with forum role name" do
            subject.find_roles(:forum, :any).should include(forum_role, tourist_role)
          end

          it "should not get roles not binded to a resource with forum role name" do
            subject.find_roles(:forum, :any).should_not include(godfather_role, sneaky_role, group_role)
          end
        end
      end

      context "on the Group class" do
        subject { Group }
        
        context "without using a user parameter" do
          it "should get all roles binded to a Group class or instance and group role name" do
            subject.find_roles(:group).should include(group_role)
          end

          it "should not get roles not binded to a Forum class or instance and forum role name" do
            subject.find_roles(:group).should_not include(tourist_role, godfather_role, sneaky_role, forum_role)
          end
        end

        context "using a user parameter" do
          it "should get all roles binded to any resource" do
            subject.find_roles(:group, admin).should include(group_role)
          end

          it "should not get roles not binded to the admin user and forum role name" do
            subject.find_roles(:group, admin).should_not include(godfather_role, tourist_role, sneaky_role, forum_role)
          end
        end

        context "using :any parameter" do
          it "should get all roles binded to any resource with forum role name" do
            subject.find_roles(:group, :any).should include(group_role)
          end

          it "should not get roles not binded to a resource with forum role name" do
            subject.find_roles(:group, :any).should_not include(godfather_role, sneaky_role, forum_role, tourist_role)
          end
        end
      end
    end

    context "using :any as role name parameter" do 
      context "on the Forum class" do
        subject { Forum }

        context "without using a user parameter" do
          it "should get all roles binded to a Forum class or instance" do
            subject.find_roles(:any).should include(forum_role, godfather_role, tourist_role, sneaky_role)
          end

          it "should not get roles not binded to a Forum class or instance" do
            subject.find_roles(:any).should_not include(group_role)
          end
        end

        context "using a user parameter" do
          it "should get all roles binded to a Forum class or instance and admin user" do
            subject.find_roles(:any, admin).should include(forum_role, godfather_role)
          end

          it "should not get roles not binded to the admin user and Forum class or instance" do
            subject.find_roles(:any, admin).should_not include(tourist_role, sneaky_role, group_role)
          end
        end

        context "using :any as user parameter" do
          it "should get all roles binded to a Forum class or instance" do
            subject.find_roles(:any, :any).should include(forum_role, godfather_role, tourist_role, sneaky_role)
          end

          it "should not get roles not binded to a Forum class or instance" do
            subject.find_roles(:any, :any).should_not include(group_role)
          end
        end
      end

      context "on the Group class" do
        subject { Group }

        context "without using a user parameter" do
          it "should get all roles binded to a Group class or instance" do
            subject.find_roles(:any).should include(group_role)
          end

          it "should not get roles not binded to a Group class or instance" do
            subject.find_roles(:any).should_not include(forum_role, godfather_role, tourist_role, sneaky_role)
          end
        end

        context "using a user parameter" do
          it "should get all roles binded to a Group class or instance and admin user" do
            subject.find_roles(:any, admin).should include(group_role)
          end

          it "should not get roles not binded to the admin user and Group class or instance" do
            subject.find_roles(:any, admin).should_not include(forum_role, godfather_role, tourist_role, sneaky_role)
          end
        end

        context "using :any as user parameter" do
          it "should get all roles binded to a Group class or instance" do
            subject.find_roles(:any, :any).should include(group_role)
          end

          it "should not get roles not binded to a Group class or instance" do
            subject.find_roles(:any, :any).should_not include(forum_role, godfather_role, tourist_role, sneaky_role)
          end
        end
      end
    end
  end

  describe "#roles" do
    subject { Forum.first }

    it { should respond_to :roles }

    context "on a Forum instance" do 
      its(:roles) { should include(forum_role, sneaky_role) } 
      its(:roles) { subject.should_not include(group_role, godfather_role, tourist_role) }
    end

    context "on a Group instance" do
      subject { Group.last }

      its(:roles) { should include(group_role) } 
      its(:roles) { should_not include(forum_role, godfather_role, sneaky_role, tourist_role) }
    end
  end

  describe "#applied_roles" do
    context "on a Forum instance" do
      subject { Forum.first }

      its(:applied_roles) { should include(forum_role, godfather_role, sneaky_role) }
      its(:applied_roles) { should_not include(group_role, tourist_role) }
    end

    context "on a Group instance" do
      subject { Group.last }

      its(:applied_roles) { should include(group_role) }
      its(:applied_roles) { should_not include(forum_role, godfather_role, sneaky_role, tourist_role) }
    end
  end
end