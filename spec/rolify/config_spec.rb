require "spec_helper"

describe Rolify do
  before do
    Rolify.use_defaults
  end

  describe :user_cname do 
    context "using defaults values" do
      subject { Rolify.user_cname }

      it { should be(User) }
    end

    context "using custom values" do
      before do
        Rolify.user_cname = "Customer"
      end

      subject { Rolify.user_cname }

      it { should be(Customer) }
    end
  end

  describe :role_cname do 
    context "using defaults values" do
      subject { Rolify.role_cname }

      it { should be(Role) }
    end

    context "using custom values" do
      before do
        Rolify.role_cname = "Privilege"
      end

      subject { Rolify.role_cname }

      it { should be(Privilege) }
    end
  end

  describe :role_cname do 
    context "using defaults values" do
      subject { Rolify.role_cname }

      it { should be(Role) }
    end

    context "using custom values" do
      before do
        Rolify.role_cname = "Privilege"
      end

      subject { Rolify.role_cname }

      it { should be(Privilege) }
    end
  end

  describe :dynamic_shortcuts do 
    context "using defaults values" do
      subject { Rolify.dynamic_shortcuts }

      it { should be(false) }
    end

    context "using custom values" do
      before do
        Rolify.dynamic_shortcuts = true
      end

      subject { Rolify.dynamic_shortcuts }

      it { should be(true) }
    end
  end

  describe :orm do 
    context "using defaults values" do
      subject { Rolify.orm }

      it { should eq("active_record") }
    end

    context "using custom values" do
      context "using :orm setter method" do
        before do
          Rolify.orm = "mongoid"
        end

        subject { Rolify.orm }

        it { should eq("mongoid") }
      end
      
      context "using :orm setter method" do
        before do
          Rolify.use_mongoid
        end

        subject { Rolify.orm }

        it { should eq("mongoid") }
      end
    end
  end
  
  describe :adapter do
    context "using defaults values" do
      subject { Rolify.adapter }

      it { should be(Rolify::Adapter::ActiveRecord) }
    end
    
    context "using custom values" do
      before do
        Rolify.use_mongoid
      end
      subject { Rolify.adapter }

      it { should be(Rolify::Adapter::Mongoid) }
    end
  end
  
  describe :configure do
    before do
      Rolify.configure do |r|
        r.role_cname = "Privilege"
        r.user_cname = "Customer"
        r.dynamic_shortcuts = true
        r.orm = "mongoid"
      end
    end
    
    its(:role_cname) { should be(Privilege) }
    its(:user_cname) { should be(Customer) }
    its(:dynamic_shortcuts) { should be(true) }
    its(:orm) { should eq("mongoid") }
    its(:adapter) { should be(Rolify::Adapter::Mongoid) }
  end
end