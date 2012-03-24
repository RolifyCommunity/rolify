shared_examples_for "#has_role_examples" do |param_name, param_method|
  context "using #{param_name} as parameter" do
    context "with a global role", :scope => :global do
      it "should add the role to the user" do
        expect { subject.has_role "root".send(param_method) }.to change{ subject.roles.count }.by(1)
      end

      it "should create a role to the roles table" do
        expect { subject.has_role "moderator".send(param_method) }.to change{ Rolify.role_cname.count }.by(1)
      end

      context "considering a new global role" do
        subject { Rolify.role_cname.last }

        its(:name) { should eq("moderator") }
        its(:resource_type) { should be(nil) }
        its(:resource_id) { should be(nil) }
      end

      context "should not create another role" do
        it "if the role was already assigned to the user" do
          subject.has_role "manager".send(param_method)
          expect { subject.has_role "manager".send(param_method) }.not_to change{ subject.roles.size }
        end

        it "if the role already exists in the db" do
          Rolify.role_cname.create :name => "god"
          expect { subject.has_role "god".send(param_method) }.not_to change{ Rolify.role_cname.count }
        end
      end
    end

    context "with a class scoped role", :scope => :class do
      it "should add the role to the user" do
        expect { subject.has_role "supervisor".send(param_method), Forum }.to change{ subject.roles.count }.by(1)
      end

      it "should create a role in the roles table" do
        expect { subject.has_role "moderator".send(param_method), Forum }.to change{ Rolify.role_cname.count }.by(1)
      end

      context "considering a new class scoped role" do
        subject { Rolify.role_cname.last }

        its(:name) { should eq("moderator") }
        its(:resource_type) { should eq(Forum.to_s) }
        its(:resource_id) { should be(nil) }
      end

      context "should not create another role" do
        it "if the role was already assigned to the user" do
          subject.has_role "warrior".send(param_method), Forum
          expect { subject.has_role "warrior".send(param_method), Forum }.not_to change{ subject.roles.size }
        end

        it "if already existing in the database" do
          Rolify.role_cname.create :name => "hacker", :resource_type => "Forum"
          expect { subject.has_role "hacker".send(param_method), Forum }.not_to change{ Rolify.role_cname.count }
        end
      end
    end

    context "with an instance scoped role", :scope => :instance do
      it "should add the role to the user" do
        expect { subject.has_role "visitor".send(param_method), Forum.last }.to change{ subject.roles.size }.by(1)
      end

      it "should create a role in the roles table" do
        expect { subject.has_role "member".send(param_method), Forum.last }.to change{ Rolify.role_cname.count }.by(1)
      end

      context "considering a new class scoped role" do
        subject { Rolify.role_cname.last }

        its(:name) { should eq("member") }
        its(:resource) { should eq(Forum.last) }
      end

      context "should not create another role" do
        it "if the role was already assigned to the user" do
          subject.has_role "anonymous".send(param_method), Forum.first
          expect { subject.has_role "anonymous".send(param_method), Forum.first }.not_to change{ subject.roles.size }
        end

        it "if already existing in the database" do
          Rolify.role_cname.create :name => "ghost", :resource_type => "Forum", :resource_id => Forum.first.id
          expect { subject.has_role "ghost".send(param_method), Forum.first }.not_to change{ Rolify.role_cname.count }
        end
      end
    end
  end
end