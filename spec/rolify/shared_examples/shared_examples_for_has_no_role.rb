shared_examples_for "#has_no_role_examples" do |param_name, param_method|
  context "using #{param_name} as parameter" do
    context "removing a global role", :scope => :global do
      context "being a global role of the user" do
        it { expect { subject.has_no_role("admin".send(param_method)) }.to change{ subject.roles.size }.by(-1) }
        
        it { subject.has_role?("admin".send(param_method)).should be_false }
        it { subject.has_role?("staff".send(param_method)).should be_true }
        it { subject.has_role?("manager".send(param_method), Group).should be_true }
        it { subject.has_role?("moderator".send(param_method), Forum.last).should be_true }
        it { subject.has_role?("moderator".send(param_method), Group.last).should be_true }
        it { subject.has_role?("anonymous".send(param_method), Forum.first).should be_true }
      end
      
      context "being a class scoped role to the user" do
        it { expect { subject.has_no_role("manager") }.to change{ subject.roles.size }.by(-1) }
        
        it { subject.has_role?("admin".send(param_method)).should be_false }
        it { subject.has_role?("staff".send(param_method)).should be_true }
        it { subject.has_role?("manager".send(param_method), Group).should be_false }
        it { subject.has_role?("moderator".send(param_method), Forum.last).should be_true }
        it { subject.has_role?("moderator".send(param_method), Group.last).should be_true }
        it { subject.has_role?("anonymous".send(param_method), Forum.first).should be_true }
      end
      
      context "being instance scoped roles to the user" do
        it { expect { subject.has_no_role("moderator") }.to change{ subject.roles.size }.by(-2) }
        
        it { subject.has_role?("admin".send(param_method)).should be_false }
        it { subject.has_role?("staff".send(param_method)).should be_true }
        it { subject.has_role?("manager".send(param_method), Group).should be_false }
        it { subject.has_role?("moderator".send(param_method), Forum.last).should be_false }
        it { subject.has_role?("moderator".send(param_method), Group.last).should be_false }
        it { subject.has_role?("anonymous".send(param_method), Forum.first).should be_true }
      end
      
      context "not being a role of the user" do
        it { expect { subject.has_no_role("superhero") }.not_to change{ subject.roles.size } }
      end
    end

    context "removing a class scoped role", :scope => :class do
      context "being a global role of the user" do
        it { expect { subject.has_no_role("warrior", Forum) }.not_to change{ subject.roles.size } }
      end
      
      context "being a class scoped role to the user" do
        it { expect { subject.has_no_role("manager", Forum) }.to change{ subject.roles.size }.by(-1) }
        
        it { subject.has_role?("warrior").should be_true }
        it { subject.has_role?("manager", Forum).should be_false }
        it { subject.has_role?("player", Forum).should be_true }
        it { subject.has_role?("moderator".send(param_method), Forum.last).should be_true }
        it { subject.has_role?("moderator".send(param_method), Group.last).should be_true }
        it { subject.has_role?("anonymous".send(param_method), Forum.first).should be_true }
      end
      
      context "being instance scoped role to the user" do
        it { expect { subject.has_no_role("moderator", Forum) }.to change{ subject.roles.size }.by(-1) }
        
        it { subject.has_role?("warrior").should be_true }
        it { subject.has_role?("manager", Forum).should be_false }
        it { subject.has_role?("player", Forum).should be_true }
        it { subject.has_role?("moderator".send(param_method), Forum.last).should be_false }
        it { subject.has_role?("moderator".send(param_method), Group.last).should be_true }
        it { subject.has_role?("anonymous".send(param_method), Forum.first).should be_true }
      end
      
      context "not being a role of the user" do
        it { expect { subject.has_no_role("manager", Group) }.not_to change{ subject.roles.size } }
      end
    end

    context "removing a instance scoped role", :scope => :instance do
      context "being a global role of the user" do
        it { expect { subject.has_no_role("soldier", Group.first) }.not_to change{ subject.roles.size } }
      end
      
      context "being a class scoped role to the user" do
        it { expect { subject.has_no_role("visitor", Forum.first) }.not_to change{ subject.roles.size } }
      end
      
      context "being instance scoped role to the user" do
        it { expect { subject.has_no_role("moderator", Forum.first) }.to change{ subject.roles.size }.by(-1) }
        
        it { subject.has_role?("soldier").should be_true }
        it { subject.has_role?("visitor", Forum).should be_true }
        it { subject.has_role?("moderator", Forum.first).should be_false }
        it { subject.has_role?("anonymous", Forum.last).should be_true }
      end
      
      context "not being a role of the user" do
        it { expect { subject.has_no_role("anonymous", Forum.first) }.not_to change{ subject.roles.size } }
      end
    end
  end
end