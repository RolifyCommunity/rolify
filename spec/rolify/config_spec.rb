require "spec_helper"

if ENV['ADAPTER'] == 'active_record'
  class ARUser < ActiveRecord::Base
    extend Rolify
  end
else
  class MUser
    include Mongoid::Document
    extend Rolify
  end
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
    context "using defaults values", :if => ENV['ADAPTER'] == 'active_record' do
      subject { Rolify.orm }

      it { should eq("active_record") }
      
      context "on the User class" do
        before do
          subject.rolify
        end
        
        subject { ARUser }
        
        its("adapter.class") { should be(Rolify::Adapter::RoleAdapter) }
      end
      
      context "on the Forum class" do
        before do
          subject.resourcify
        end
        
        subject { Forum }
        
        its("adapter.class") { should be(Rolify::Adapter::ResourceAdapter) }
      end
    end

    context "using custom values", :if => ENV['ADAPTER'] == 'mongoid' do
      context "using :orm setter method" do
        before do
          Rolify.orm = "mongoid"
        end

        subject { Rolify.orm }

        it { should eq("mongoid") }
        
        context "on the User class" do
          before do
            MUser.rolify
          end

          subject { MUser }
          
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
      
      context "using :use_mongoid method" do
        before do
          Rolify.use_mongoid
        end

        subject { Rolify.orm }

        it { should eq("mongoid") }
        
        context "on the User class" do
          before do
            MUser.rolify
          end

          subject { MUser }
          
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
        config.orm = "mongoid"
      end
    end
    
    its(:dynamic_shortcuts) { should be_true }
    its(:orm) { should eq("mongoid") }
    
    context "on the User class", :if => ENV['ADAPTER'] == 'mongoid' do
      before do
        MUser.rolify
      end

      subject { MUser }
      
      it { should satisfy { |u| u.include? Rolify::Role }}
      it { should satisfy { |u| u.singleton_class.include? Rolify::Dynamic } }
      its("adapter.class") { should be(Rolify::Adapter::RoleAdapter) }
    end

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