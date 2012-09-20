shared_examples_for "#remove_role_examples" do |param_name, param_method|
  context "using #{param_name} as parameter" do
    context "removing a global role", :scope => :global do
      context "being a global role of the user" do
        it { expect { subject.remove_role("admin".send(param_method)) }.to change { subject.roles.size }.by(-1) }

        it { should_not have_role("admin".send(param_method)) }
        it { should     have_role("staff".send(param_method)) }
        it { should     have_role("manager".send(param_method), Group) }
        it { should     have_role("moderator".send(param_method), Forum.last) }
        it { should     have_role("moderator".send(param_method), Group.last) }
        it { should     have_role("anonymous".send(param_method), Forum.first) }
      end

      context "being a class scoped role to the user" do
        it { expect { subject.remove_role("manager".send(param_method)) }.to change { subject.roles.size }.by(-1) }

        it { should_not have_role("admin".send(param_method)) }
        it { should     have_role("staff".send(param_method)) }
        it { should_not have_role("manager".send(param_method), Group) }
        it { should     have_role("moderator".send(param_method), Forum.last) }
        it { should     have_role("moderator".send(param_method), Group.last) }
        it { should     have_role("anonymous".send(param_method), Forum.first) }
      end

      context "being instance scoped roles to the user" do
        it { expect { subject.remove_role("moderator".send(param_method)) }.to change { subject.roles.size }.by(-2) }

        it { should_not have_role("admin".send(param_method)) }
        it { should     have_role("staff".send(param_method)) }
        it { should_not have_role("manager".send(param_method), Group) }
        it { should_not have_role("moderator".send(param_method), Forum.last) }
        it { should_not have_role("moderator".send(param_method), Group.last) }
        it { should     have_role("anonymous".send(param_method), Forum.first) }
      end

      context "not being a role of the user" do
        it { expect { subject.remove_role("superhero".send(param_method)) }.not_to change { subject.roles.size } }
      end

      context "used by another user" do
        before do
          user = user_class.last
          user.add_role "staff".send(param_method)
        end

        it { expect { subject.remove_role("staff".send(param_method)) }.not_to change { role_class.count } }

        it { should_not have_role("admin".send(param_method)) }
        it { should_not have_role("staff".send(param_method)) }
        it { should_not have_role("manager".send(param_method), Group) }
        it { should_not have_role("moderator".send(param_method), Forum.last) }
        it { should_not have_role("moderator".send(param_method), Group.last) }
        it { should     have_role("anonymous".send(param_method), Forum.first) }
      end

      context "not used by anyone else" do
        before do
          subject.add_role "nobody".send(param_method)
        end

        it { expect { subject.remove_role("nobody".send(param_method)) }.to change { role_class.count }.by(-1) }
      end
    end

    context "removing a class scoped role", :scope => :class do
      context "being a global role of the user" do
        it { expect { subject.remove_role("warrior".send(param_method), Forum) }.not_to change{ subject.roles.size } }
      end

      context "being a class scoped role to the user" do
        it { expect { subject.remove_role("manager".send(param_method), Forum) }.to change{ subject.roles.size }.by(-1) }

        it { should     have_role("warrior") }
        it { should_not have_role("manager", Forum) }
        it { should     have_role("player", Forum) }
        it { should     have_role("moderator".send(param_method), Forum.last) }
        it { should     have_role("moderator".send(param_method), Group.last) }
        it { should     have_role("anonymous".send(param_method), Forum.first) }
      end

      context "being instance scoped role to the user" do
        it { expect { subject.remove_role("moderator".send(param_method), Forum) }.to change { subject.roles.size }.by(-1) }

        it { should     have_role("warrior") }
        it { should_not have_role("manager", Forum) }
        it { should     have_role("player", Forum) }
        it { should_not have_role("moderator".send(param_method), Forum.last) }
        it { should     have_role("moderator".send(param_method), Group.last) }
        it { should     have_role("anonymous".send(param_method), Forum.first) }
      end

      context "not being a role of the user" do
        it { expect { subject.remove_role("manager".send(param_method), Group) }.not_to change { subject.roles.size } }
      end
    end

    context "removing a instance scoped role", :scope => :instance do
      context "being a global role of the user" do
        it { expect { subject.remove_role("soldier".send(param_method), Group.first) }.not_to change { subject.roles.size } }
      end

      context "being a class scoped role to the user" do
        it { expect { subject.remove_role("visitor".send(param_method), Forum.first) }.not_to change { subject.roles.size } }
      end

      context "being instance scoped role to the user" do
        it { expect { subject.remove_role("moderator".send(param_method), Forum.first) }.to change { subject.roles.size }.by(-1) }

        it { should     have_role("soldier") }
        it { should     have_role("visitor", Forum) }
        it { should_not have_role("moderator", Forum.first) }
        it { should     have_role("anonymous", Forum.last) }
      end

      context "not being a role of the user" do
        it { expect { subject.remove_role("anonymous".send(param_method), Forum.first) }.not_to change { subject.roles.size } }
      end
    end
  end
end
