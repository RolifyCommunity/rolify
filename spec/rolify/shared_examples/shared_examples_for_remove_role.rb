shared_examples_for "#remove_role_examples" do |param_name, param_method|
  context "using #{param_name} as parameter" do
    context "removing a global role", :scope => :global do
      context "being a global role of the user" do
        it { expect { subject.remove_role("admin".send(param_method)) }.to change { subject.roles.size }.by(-1) }
        
        it { subject.has_role?("admin".send(param_method)).should be_false }
        it { subject.has_role?("staff".send(param_method)).should be_true }
        it { subject.has_role?("manager".send(param_method), Group).should be_true }
        it { subject.has_role?("moderator".send(param_method), Forum.last).should be_true }
        it { subject.has_role?("moderator".send(param_method), Group.last).should be_true }
        it { subject.has_role?("anonymous".send(param_method), Forum.first).should be_true }
      end
      
      context "being a class scoped role to the user" do
        it { expect { subject.remove_role("manager".send(param_method)) }.to change { subject.roles.size }.by(-1) }
        
        it { subject.has_role?("admin".send(param_method)).should be_false }
        it { subject.has_role?("staff".send(param_method)).should be_true }
        it { subject.has_role?("manager".send(param_method), Group).should be_false }
        it { subject.has_role?("moderator".send(param_method), Forum.last).should be_true }
        it { subject.has_role?("moderator".send(param_method), Group.last).should be_true }
        it { subject.has_role?("anonymous".send(param_method), Forum.first).should be_true }
      end
      
      context "being instance scoped roles to the user" do
        it { expect { subject.remove_role("moderator".send(param_method)) }.to change { subject.roles.size }.by(-2) }
        
        it { subject.has_role?("admin".send(param_method)).should be_false }
        it { subject.has_role?("staff".send(param_method)).should be_true }
        it { subject.has_role?("manager".send(param_method), Group).should be_false }
        it { subject.has_role?("moderator".send(param_method), Forum.last).should be_false }
        it { subject.has_role?("moderator".send(param_method), Group.last).should be_false }
        it { subject.has_role?("anonymous".send(param_method), Forum.first).should be_true }
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
        
        it { subject.has_role?("admin".send(param_method)).should be_false }
        it { subject.has_role?("staff".send(param_method)).should be_false }
        it { subject.has_role?("manager".send(param_method), Group).should be_false }
        it { subject.has_role?("moderator".send(param_method), Forum.last).should be_false }
        it { subject.has_role?("moderator".send(param_method), Group.last).should be_false }
        it { subject.has_role?("anonymous".send(param_method), Forum.first).should be_true }
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
        
        it { subject.has_role?("warrior").should be_true }
        it { subject.has_role?("manager", Forum).should be_false }
        it { subject.has_role?("player", Forum).should be_true }
        it { subject.has_role?("moderator".send(param_method), Forum.last).should be_true }
        it { subject.has_role?("moderator".send(param_method), Group.last).should be_true }
        it { subject.has_role?("anonymous".send(param_method), Forum.first).should be_true }
      end
      
      context "being instance scoped role to the user" do
        it { expect { subject.remove_role("moderator".send(param_method), Forum) }.to change { subject.roles.size }.by(-1) }
        
        it { subject.has_role?("warrior").should be_true }
        it { subject.has_role?("manager", Forum).should be_false }
        it { subject.has_role?("player", Forum).should be_true }
        it { subject.has_role?("moderator".send(param_method), Forum.last).should be_false }
        it { subject.has_role?("moderator".send(param_method), Group.last).should be_true }
        it { subject.has_role?("anonymous".send(param_method), Forum.first).should be_true }
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
        
        it { subject.has_role?("soldier").should be_true }
        it { subject.has_role?("visitor", Forum).should be_true }
        it { subject.has_role?("moderator", Forum.first).should be_false }
        it { subject.has_role?("anonymous", Forum.last).should be_true }
      end
      
      context "not being a role of the user" do
        it { expect { subject.remove_role("anonymous".send(param_method), Forum.first) }.not_to change { subject.roles.size } }
      end
    end
  end
end