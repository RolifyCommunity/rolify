require "spec_helper"
require "active_record"

class ARUser < ActiveRecord::Base
  extend Rolify
end

describe Rolify do
  before do
    Rolify.use_defaults
  end

  describe :dynamic_shortcuts do 
    context "using defaults values" do
      subject { Rolify.dynamic_shortcuts }

      it { should be_false }
    end

    context "using custom values" do
      before do
        Rolify.dynamic_shortcuts = true
      end

      subject { Rolify.dynamic_shortcuts }

      it { should be_true }
    end
  end

  describe :orm do 
    context "using defaults values" do
      subject { Rolify.orm }

      it { should eq("active_record") }
      
      context "on the User class" do
        before do
          ARUser.rolify
        end
        
        subject { ARUser }
        
        its("adapter.class") { should be(Rolify::Adapter::RoleAdapter) }
      end
      
      context "on the Forum class" do
        before do
          Forum.resourcify
        end
        
        subject { Forum }
        
        its("adapter.class") { should be(Rolify::Adapter::ResourceAdapter) }
      end
    end

    context "using custom values" do
      context "using :orm setter method" do

        subject { Rolify.orm }

        context "on the Forum class" do
          before do
            Forum.resourcify
          end

          subject { Forum }

          its("adapter.class") { should be(Rolify::Adapter::ResourceAdapter) }
        end
      end
    end
    
    describe :dynamic_shortcuts do
      context "using defaults values" do
        subject { Rolify.dynamic_shortcuts }

        it { should be_false }
      end
      
      context "using custom values" do
        context "using :dynamic_shortcuts setter method" do
          before do
            Rolify.dynamic_shortcuts = true
          end

          subject { Rolify.dynamic_shortcuts }

          it { should be_true }
        end

        context "using :use_dynamic_shortcuts method" do
          before do
            Rolify.use_dynamic_shortcuts
          end

          subject { Rolify.dynamic_shortcuts }

          it { should be_true }
        end
      end
    end
  end
  
  describe :configure do
    before do
      Rolify.configure do |config|
        config.dynamic_shortcuts = true
      end
    end
    
    its(:dynamic_shortcuts) { should be_true }
    
    context "on the Forum class" do
      before do
        Forum.resourcify
      end

      subject { Forum }
      
      it { should satisfy { |u| u.include? Rolify::Resource }}
      its("adapter.class") { should be(Rolify::Adapter::ResourceAdapter) }
    end
  end
end