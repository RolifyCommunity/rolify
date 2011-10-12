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
    before { 
      run_generator 
    }
    
    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }
      it { should exist }
      it { should contain "Rolify.user_cname = User" }
      it { should contain "Rolify.role_cname = Role" }
      it { should contain "Rolify.dynamic_shortcuts = true" }
    end
    
    describe 'migration file' do
      subject { file('db/migrate/rolify_create_roles.rb') }
      
      # should be_a_migration - verifies the file exists with a migration timestamp as part of the filename 
      it { should be_a_migration }
    end
  end

  describe 'specifying user and role names' do
    before { 
      run_generator %w(Rank Client)
    }
    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }
      it { should exist }
      it { should contain "Rolify.user_cname = Client" }
      it { should contain "Rolify.role_cname = Rank" }
      it { should contain "Rolify.dynamic_shortcuts = true" }
    end
    
    describe 'migration file' do
      subject { file('db/migrate/rolify_create_ranks.rb') }
      
      # should be_a_migration - verifies the file exists with a migration timestamp as part of the filename 
      it { should be_a_migration }
      #it { should contain "create_table(:ranks)" }
    end
  end
  
  describe 'specifying no dynamic shortcuts' do
    before { run_generator %w(--no-dynamic_shortcuts) }
    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }
      it { should exist }
      it { should contain "Rolify.dynamic_shortcuts = false" }
    end
    
    describe 'migration file' do
      subject { file('db/migrate/rolify_create_roles.rb') }
      
      # should be_a_migration - verifies the file exists with a migration timestamp as part of the filename 
      it { should be_a_migration }
    end
  end
end