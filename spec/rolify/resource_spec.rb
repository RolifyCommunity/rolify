require "spec_helper"

describe Rolify::Resource do
  before(:all) do
    reset_defaults
    silence_warnings { User.rolify }
    Forum.resourcify
    Group.resourcify
    Team.resourcify
    Organization.resourcify
    Role.destroy_all
  end

  # Users
  let(:admin)   { User.first }
  let(:tourist) { User.last }
  let(:captain) { User.where(:login => "god").first }

  # roles
  let!(:forum_role)      { admin.add_role(:forum, Forum.first) }
  let!(:godfather_role)  { admin.add_role(:godfather, Forum) }
  let!(:group_role)      { admin.add_role(:group, Group.last) }
  let!(:grouper_role)    { admin.add_role(:grouper, Group.first) }
  let!(:tourist_role)    { tourist.add_role(:forum, Forum.last) }
  let!(:sneaky_role)     { tourist.add_role(:group, Forum.first) }
  let!(:captain_role)    { captain.add_role(:captain, Team.first) }
  let!(:player_role)     { captain.add_role(:player, Team.last) }
  let!(:company_role)    { admin.add_role(:owner, Company.first) }

  describe ".with_roles" do
    subject { Group }

    it { should respond_to(:find_roles).with(1).arguments }
    it { should respond_to(:find_roles).with(2).arguments }

    context "with a role name as argument" do
      context "on the Forum class" do
        subject { Forum }

        it "should include Forum instances with forum role" do
          subject.with_role(:forum).should =~ [ Forum.first, Forum.last ]
        end

        it "should include Forum instances with godfather role" do
          subject.with_role(:godfather).should =~ Forum.all
        end

        it "should be able to modify the resource", :if => ENV['ADAPTER'] == 'active_record' do
          forum_resource = subject.with_role(:forum).first
          forum_resource.name = "modified name"
          expect { forum_resource.save }.not_to raise_error
        end
      end

      context "on the Group class" do
        subject { Group }

        it "should include Group instances with group role" do
          subject.with_role(:group).should =~ [ Group.last ]
        end
      end

      context "on a Group instance" do
        subject { Group.last }

        it "should ignore nil entries" do
          subject.subgroups.with_role(:group).should =~ [ ]
        end
      end
    end

    context "with an array of role names as argument" do
      context "on the Group class" do
        subject { Group }

        it "should include Group instances with both group and grouper roles" do
          subject.with_roles([:group, :grouper]).should =~ [ Group.first, Group.last ]
        end
      end
    end

    context "with a role name and a user as arguments" do
      context "on the Forum class" do
        subject { Forum }

        it "should get all Forum instances binded to the forum role and the admin user" do
          subject.with_role(:forum, admin).should =~ [ Forum.first ]
        end

        it "should get all Forum instances binded to the forum role and the tourist user" do
          subject.with_role(:forum, tourist).should =~ [ Forum.last ]
        end

        it "should get all Forum instances binded to the godfather role and the admin user" do
          subject.with_role(:godfather, admin).should =~ Forum.all.to_a
        end

        it "should get all Forum instances binded to the godfather role and the tourist user" do
          subject.with_role(:godfather, tourist).should be_empty
        end

        it "should get Forum instances binded to the group role and the tourist user" do
          subject.with_role(:group, tourist).should =~ [ Forum.first ]
        end

        it "should not get Forum instances not binded to the group role and the tourist user" do
          subject.with_role(:group, tourist).should_not include(Forum.last)
        end
      end

      context "on the Group class" do
        subject { Group }

        it "should get all resources binded to the group role and the admin user" do
          subject.with_role(:group, admin).should =~ [ Group.last ]
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
          subject.with_roles([:forum, :group], tourist).should =~ [ Forum.first, Forum.last ]
        end

      end

      context "on the Group class" do
        subject { Group }

        it "should get Group instances binded to the group and grouper roles and the admin user" do
          subject.with_roles([:group, :grouper], admin).should =~ [ Group.first, Group.last ]
        end

      end
    end

    context "with a model not having ID column" do
      subject { Team }

      it "should find Team instance using team_code column" do
        subject.with_roles([:captain, :player], captain).should =~ [ Team.first, Team.last ]
      end
    end

    context "with a resource using STI" do
      subject { Organization }
      it "should find instances of children classes" do
        subject.with_roles(:owner, admin).should =~ [ Company.first ]
      end
    end
  end


  describe ".without_roles" do
    subject { Group }

    it { should respond_to(:find_roles).with(1).arguments }
    it { should respond_to(:find_roles).with(2).arguments }

    context "with a role name as argument" do
      context "on the Forum class" do
        subject { Forum }

        it "should not include Forum instances with forum role" do
          subject.without_role(:forum).should_not =~ [ Forum.first, Forum.last ]
        end

        it "should not include Forum instances with godfather role" do
          subject.without_role(:godfather).should be_empty
        end

        it "should be able to modify the resource", :if => ENV['ADAPTER'] == 'active_record' do
          forum_resource = subject.without_role(:forum).first
          forum_resource.name = "modified name"
          expect { forum_resource.save }.not_to raise_error
        end
      end

      context "on the Group class" do
        subject { Group }

        it "should not include Group instances with group role" do
          subject.without_role(:group).should_not =~ [ Group.last ]
        end
      end

    end

    context "with an array of role names as argument" do
      context "on the Group class" do
        subject { Group }

        it "should include Group instances without either the group and grouper roles" do
          subject.without_roles([:group, :grouper]).should_not =~ [ Group.first, Group.last ]
        end
      end
    end

    context "with a role name and a user as arguments" do
      context "on the Forum class" do
        subject { Forum }

        it "should get all Forum instances the admin user does not have the forum role" do
          subject.without_role(:forum, admin).should_not =~ [ Forum.first ]
        end

        it "should get all Forum instances the tourist user does not have the forum role" do
          subject.without_role(:forum, tourist).should_not =~ [ Forum.last ]
        end

        it "should get all Forum instances the admin user does not have the godfather role" do
          subject.without_role(:godfather, admin).should_not =~ Forum.all
        end

        it "should get all Forum instances tourist user does not have the godfather role" do
          subject.without_role(:godfather, tourist).should =~ Forum.all
        end

        it "should get Forum instances the tourist user does not have the group role" do
          subject.without_role(:group, tourist).should_not =~ [ Forum.first ]
        end

        it "should get Forum instances the tourist user does not have the group role" do
          subject.without_role(:group, tourist).should_not =~ [ Forum.first ]
        end
      end

      context "on the Group class" do
        subject { Group }

        it "should get all resources not bounded to the group role and the admin user" do
          subject.without_role(:group, admin).should =~ [ Group.first ]
        end

        it "should not get resources bound to the group role and the admin user" do
          subject.without_role(:group, admin).should include(Group.first)
        end
      end
    end

    context "with an array of role names and a user as arguments" do
      context "on the Forum class" do
        subject { Forum }

        it "should get Forum instances not bound to the forum and group roles and the tourist user" do
          subject.without_roles([:forum, :group], tourist).should_not =~ [ Forum.first, Forum.last ]
        end

      end

      context "on the Group class" do
        subject { Group }

        it "should get Group instances binded to the group and grouper roles and the admin user" do
          subject.without_roles([:group, :grouper], admin).should =~ [ ]
        end

      end
    end

    context "with a model not having ID column" do
      subject { Team }

      it "should find Team instance not using team_code column" do
        subject.without_roles(:captain, captain).should =~ [ Team.last ]
      end
    end

    context "with a resource using STI" do
      subject { Organization }
      it "should exclude instances of children classes with matching" do
        subject.without_role(:owner, admin).should_not =~ [ Company.first ]
      end
    end
  end

  describe ".find_role" do

    context "without using a role name parameter" do

      context "on the Forum class" do
        subject { Forum }

        it "should get all roles binded to a Forum class or instance" do
          subject.find_roles.to_a.should =~ [ forum_role, godfather_role, tourist_role, sneaky_role ]
        end

        it "should not get roles not binded to a Forum class or instance" do
          subject.find_roles.should_not include(group_role)
        end

        context "using :any parameter" do
          it "should get all roles binded to any Forum class or instance" do
            subject.find_roles(:any, :any).to_a.should =~ [ forum_role, godfather_role, tourist_role, sneaky_role ]
          end

          it "should not get roles not binded to a Forum class or instance" do
            subject.find_roles(:any, :any).should_not include(group_role)
          end
        end
      end

      context "on the Group class" do
        subject { Group }

        it "should get all roles binded to a Group class or instance" do
          subject.find_roles.to_a.should =~ [ group_role, grouper_role ]
        end

        it "should not get roles not binded to a Group class or instance" do
          subject.find_roles.should_not include(forum_role, godfather_role, tourist_role, sneaky_role)
        end

        context "using :any parameter" do
          it "should get all roles binded to Group class or instance" do
            subject.find_roles(:any, :any).to_a.should =~ [ group_role, grouper_role ]
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
            subject.find_roles(:forum, admin).to_a.should =~ [ forum_role ]
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

    context "with a resource using STI" do
      subject{ Organization }
      it "should find instances of children classes" do
        subject.find_roles(:owner, admin).should =~ [company_role]
      end
    end
  end

  describe "#roles" do
    before(:all) { Role.destroy_all }
    subject { Forum.first }

    it { should respond_to :roles }

    context "on a Forum instance" do
      its(:roles) { should match_array( [ forum_role, sneaky_role ]) }
      its(:roles) { should_not include(group_role, godfather_role, tourist_role) }
    end

    context "on a Group instance" do
      subject { Group.last }

      its(:roles) { should eq([ group_role ]) }
      its(:roles) { should_not include(forum_role, godfather_role, sneaky_role, tourist_role) }

      context "when deleting a Group instance" do
        subject do
          Group.create(:name => "to delete")
        end

        before do
          subject.roles.create :name => "group_role1"
          subject.roles.create :name => "group_role2"
        end

        it "should remove the roles binded to this instance" do
          expect { subject.destroy }.to change { Role.count }.by(-2)
        end
      end
    end
  end

  describe "#applied_roles" do
    context "on a Forum instance" do
      subject { Forum.first }

      its(:applied_roles) { should =~ [ forum_role, godfather_role, sneaky_role ] }
      its(:applied_roles) { should_not include(group_role, tourist_role) }
    end

    context "on a Group instance" do
      subject { Group.last }

      its(:applied_roles) { should =~ [ group_role ] }
      its(:applied_roles) { should_not include(forum_role, godfather_role, sneaky_role, tourist_role) }
    end
  end

  describe '.resource_types' do

    it 'include all models that call resourcify' do
      Rolify.resource_types.should include("HumanResource", "Forum", "Group",
                                          "Team", "Organization")
    end
  end
end
