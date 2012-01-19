require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/rolify/role/role_generator'

describe Rolify::Generators::RoleGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)
  before { 
    prepare_destination
  }

  describe 'no arguments' do
    before(:all) { arguments [] }

    before { 
      capture(:stdout) {
        generator.create_file "app/models/user.rb" do
          "class User < ActiveRecord::Base\nend"
        end
      }
      run_generator 
    }
    
    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }
      it { should exist }
      it { should contain "c.user_cname = \"User\"" }
      it { should contain "c.dynamic_shortcuts = false" }
    end
    
    describe 'app/models/user.rb' do
      subject { file('app/models/user.rb') }
      it { should contain "rolify" }
    end
    
    describe 'migration file' do
      subject { file('db/migrate/rolify_create_roles.rb') }
      
      # should be_a_migration - verifies the file exists with a migration timestamp as part of the filename 
      it { should be_a_migration }
    end
  end

  describe 'specifying user and role names' do
    before(:all) { arguments %w(Rank Client) }
    
    before { 
      capture(:stdout) {
        generator.create_file "app/models/client.rb" do
          "class Client < ActiveRecord::Base\nend"
        end
      }
      run_generator
    }
    
    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }
      it { should exist }
      it { should contain "c.user_cname = \"Client\"" }
      it { should contain "c.dynamic_shortcuts = false" }
    end
    
    describe 'app/models/client.rb' do
      subject { file('app/models/client.rb') }
      it { should contain "rolify" }
    end
    
    describe 'migration file' do
      subject { file('db/migrate/rolify_create_ranks.rb') }
      
      # should be_a_migration - verifies the file exists with a migration timestamp as part of the filename 
      it { should be_a_migration }
      #it { should contain "create_table(:ranks)" }
    end
  end
  
  describe 'specifying dynamic shortcuts' do
    before(:all) { arguments [ "Role", "User", "--dynamic_shortcuts" ] }
    
    before { 
      capture(:stdout) {
        generator.create_file "app/models/user.rb" do
          "class User < ActiveRecord::Base\nend"
        end
      }
      run_generator
    }
      
    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }
      it { should exist }
      it { should contain "c.dynamic_shortcuts = true" }
    end
    
    describe 'app/models/user.rb' do
      subject { file('app/models/user.rb') }
      it { should contain "rolify" }
    end
    
    describe 'migration file' do
      subject { file('db/migrate/rolify_create_roles.rb') }
      
      # should be_a_migration - verifies the file exists with a migration timestamp as part of the filename 
      it { should be_a_migration }
    end
  end
  
  describe 'specifying orm adapter' do 
    before(:all) { arguments [ "Role", "User", "mongoid" ] }
    
    before { 
      capture(:stdout) {
        generator.create_file "app/models/user.rb" do
          "class User < ActiveRecord::Base\nend"
        end
      }
      run_generator
    }
      
    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }
      it { should exist }
      it { should_not contain "# c.use_mongoid" }
    end
    
    describe 'app/models/user.rb' do
      subject { file('app/models/user.rb') }
      it { should contain "rolify" }
    end
  end
end