shared_examples_for "#add_role_examples" do |param_name, param_method|
  context "using #{param_name} as parameter" do
    context "with a global role", :scope => :global do
      it "should add the role to the user" do
        expect { subject.add_role "root".send(param_method) }.to change { subject.roles.count }.by(1)
      end

      it "should create a role to the roles table" do
        expect { subject.add_role "moderator".send(param_method) }.to change { role_class.count }.by(1)
      end

      context "considering a new global role" do
        subject { role_class.last }

        its(:name) { should eq("moderator") }
        its(:resource_type) { should be(nil) }
        its(:resource_id) { should be(nil) }
      end

      context "should not create another role" do
        it "if the role was already assigned to the user" do
          subject.add_role "manager".send(param_method)
          expect { subject.add_role "manager".send(param_method) }.not_to change { subject.roles.size }
        end

        it "if the role already exists in the db" do
          role_class.create :name => "god"
          expect { subject.add_role "god".send(param_method) }.not_to change { role_class.count }
        end
      end
    end

    context "with a class scoped role", :scope => :class do
      it "should add the role to the user" do
        expect { subject.add_role "supervisor".send(param_method), Forum }.to change { subject.roles.count }.by(1)
      end

      it "should create a role in the roles table" do
        expect { subject.add_role "moderator".send(param_method), Forum }.to change { role_class.count }.by(1)
      end

      context "considering a new class scoped role" do
        subject { role_class.last }

        its(:name) { should eq("moderator") }
        its(:resource_type) { should eq(Forum.to_s) }
        its(:resource_id) { should be(nil) }
      end

      context "should not create another role" do
        it "if the role was already assigned to the user" do
          subject.add_role "warrior".send(param_method), Forum
          expect { subject.add_role "warrior".send(param_method), Forum }.not_to change { subject.roles.count }
        end

        it "if already existing in the database" do
          role_class.create :name => "hacker", :resource_type => "Forum"
          expect { subject.add_role "hacker".send(param_method), Forum }.not_to change { role_class.count }
        end
      end

      context "and resource is a STI subclass", :if => (Rolify.orm == 'active_record') do
        let(:klass) { Class.new(Forum) }

        it "should use the resources class name instead of the base_class for resource_type" do
          subject.add_role "supervisor".send(param_method), klass
          role_class.last.resource_type.should eq(klass.to_s)
        end
      end
    end

    context "with an instance scoped role", :scope => :instance do
      it "should add the role to the user" do
        expect { subject.add_role "visitor".send(param_method), Forum.last }.to change { subject.roles.count }.by(1)
      end

      it "should create a role in the roles table" do
        expect { subject.add_role "member".send(param_method), Forum.last }.to change { role_class.count }.by(1)
      end

      context "considering a new class scoped role" do
        subject { role_class.last }

        its(:name) { should eq("member") }
        its(:resource) { should eq(Forum.last) }
      end

      context "should not create another role" do
        it "if the role was already assigned to the user" do
          subject.add_role "anonymous".send(param_method), Forum.first
          expect { subject.add_role "anonymous".send(param_method), Forum.first }.not_to change { subject.roles.size }
        end

        it "if already existing in the database" do
          role_class.create :name => "ghost", :resource_type => "Forum", :resource_id => Forum.first.id
          expect { subject.add_role "ghost".send(param_method), Forum.first }.not_to change { role_class.count }
        end
      end

      context "and resource is an STI type", :if => (Rolify.orm == 'active_record'), :sti => true do
        let(:klass) { Class.new(Forum) }

        it "should use the base_class name for resource_type" do
          subject.add_role "supervisor".send(param_method), klass.last
          role_class.last.resource_type.should eq(Forum.to_s)
        end
      end
    end
  end
end
