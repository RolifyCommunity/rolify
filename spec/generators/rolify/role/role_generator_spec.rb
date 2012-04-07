require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/rolify/role/role_generator'

describe Rolify::Generators::RoleGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)
  teardown :cleanup_destination_root
  
  before { 
    prepare_destination
  }
  
  def cleanup_destination_root
    FileUtils.rm_rf destination_root
  end

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
      it { should contain "Rolify.configure do |config|"}
      it { should contain "# config.use_dynamic_shortcuts" }
      it { should contain "# config.use_mongoid" }
    end
    
    describe 'app/models/role.rb' do
      subject { file('app/models/role.rb') }
      it { should exist }
      it { should contain "class Role < ActiveRecord::Base" }
      it { should contain "has_and_belongs_to_many :users, :join_table => :users_roles" }
      it { should contain "belongs_to :resource, :polymorphic => true" }
    end
    
    describe 'app/models/user.rb' do
      subject { file('app/models/user.rb') }
      it { should contain "rolify" }
    end
    
    describe 'migration file' do
      subject { migration_file('db/migrate/rolify_create_roles.rb') }
      
      it { should be_a_migration }
      it { should contain "create_table(:roles) do" }
      it { should contain "create_table(:users_roles, :id => false) do" }
    end
  end

  describe 'specifying user and role names' do
    before(:all) { arguments %w(AdminRole AdminUser) }
    
    before { 
      capture(:stdout) {
        generator.create_file "app/models/admin_user.rb" do
          "class AdminUser < ActiveRecord::Base\nend"
        end
      }
      run_generator
    }
    
    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }
      
      it { should exist }
      it { should contain "Rolify.configure do |config|"}
      it { should contain "# config.use_dynamic_shortcuts" }
      it { should contain "# config.use_mongoid" }
    end
    
    describe 'app/models/rank.rb' do
      subject { file('app/models/admin_role.rb') }
      
      it { should exist }
      it { should contain "class AdminRole < ActiveRecord::Base" }
      it { should contain "has_and_belongs_to_many :admin_users, :join_table => :admin_users_admin_roles" }
      it { should contain "belongs_to :resource, :polymorphic => true" }
    end
    
    describe 'app/models/client.rb' do
      subject { file('app/models/admin_user.rb') }
      
      it { should contain "rolify" }
    end
    
    describe 'migration file' do
      subject { migration_file('db/migrate/rolify_create_admin_roles.rb') }
      
      it { should be_a_migration }
      it { should contain "create_table(:admin_roles)" }
      it { should contain "create_table(:admin_users_admin_roles, :id => false) do" }
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
      it { should contain "Rolify.configure do |config|"}
      it { should_not contain "# config.use_dynamic_shortcuts" }
      it { should contain "# config.use_mongoid" }
    end
    
    describe 'app/models/role.rb' do
      subject { file('app/models/role.rb') }
      it { should exist }
      it { should contain "class Role < ActiveRecord::Base" }
      it { should contain "has_and_belongs_to_many :users, :join_table => :users_roles" }
      it { should contain "belongs_to :resource, :polymorphic => true" }
    end
    
    describe 'app/models/user.rb' do
      subject { file('app/models/user.rb') }
      it { should contain "rolify" }
    end
    
    describe 'migration file' do
      subject { migration_file('db/migrate/rolify_create_roles.rb') }
      
      it { should be_a_migration }
      it { should contain "create_table(:roles) do" }
      it { should contain "create_table(:users_roles, :id => false) do" }
    end
  end
  
  describe 'specifying orm adapter' do 
    before(:all) { arguments [ "Role", "User", "mongoid" ] }
    
    before { 
      capture(:stdout) {
        generator.create_file "app/models/user.rb" do
          <<-CLASS 
          class User
            include Mongoid::Document

            field :login, :type => String
          end
          CLASS
        end
      }
      run_generator
    }
      
    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }
      it { should exist }
      it { should contain "Rolify.configure do |config|"}
      it { should_not contain "# config.use_mongoid" }
      it { should contain "# config.use_dynamic_shortcuts" }
    end
    
    describe 'app/models/role.rb' do
      subject { file('app/models/role.rb') }
      it { should exist }
      it { should contain "class Role\n" }
      it { should contain "has_and_belongs_to_many :users\n" }
      it { should contain "belongs_to :resource, :polymorphic => true" }
      it { should contain "field :name, :type => String" }
      it { should contain "index :name, unique: true" }
      it { should contain "  index(\n"
                          "    [\n"
                          "      [:name, Mongo::ASCENDING],\n"
                          "      [:resource_type, Mongo::ASCENDING],\n"
                          "      [:resource_id, Mongo::ASCENDING]\n"
                          "    ],\n"
                          "    unique: true\n"
                          "  )\n" }
    end
    
    describe 'app/models/user.rb' do
      subject { file('app/models/user.rb') }
      it { should contain "rolify" }
    end
  end
end