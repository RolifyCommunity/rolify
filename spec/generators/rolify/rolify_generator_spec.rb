require 'generators_helper'

# Generators are not automatically loaded by Rails
require 'generators/rolify/rolify_generator'

require 'mongoid'
describe Rolify::Generators::RolifyGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../tmp", __FILE__)
  teardown :cleanup_destination_root
  
  before { 
    prepare_destination
  }
  
  def cleanup_destination_root
    FileUtils.rm_rf destination_root
  end

  describe 'specifying only Role class name' do
    before(:all) { arguments %w(Role) }

    before { 
      capture(:stdout) {
        generator.create_file "app/models/user.rb" do
<<-RUBY
  class User < ActiveRecord::Base
  end
RUBY
        end
      }
      require File.join(destination_root, "app/models/user.rb")
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
      it { should contain /class User < ActiveRecord::Base\n  rolify\n/ }
    end
    
    describe 'migration file' do
      subject { migration_file('db/migrate/rolify_create_roles.rb') }
      
      it { should be_a_migration }
      it { should contain "create_table(:roles) do" }
      it { should contain "create_table(:users_roles, :id => false) do" }
    end
  end

  describe 'specifying User and Role class names' do
    before(:all) { arguments %w(AdminRole AdminUser) }
    
    before { 
      capture(:stdout) {
        generator.create_file "app/models/admin_user.rb" do
          "class AdminUser < ActiveRecord::Base\nend"
        end
      }
      require File.join(destination_root, "app/models/admin_user.rb")
      run_generator
    }
    
    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }
      
      it { should exist }
      it { should contain "Rolify.configure(\"AdminRole\") do |config|"}
      it { should contain "# config.use_dynamic_shortcuts" }
      it { should contain "# config.use_mongoid" }
    end
    
    describe 'app/models/admin_role.rb' do
      subject { file('app/models/admin_role.rb') }
      
      it { should exist }
      it { should contain "class AdminRole < ActiveRecord::Base" }
      it { should contain "has_and_belongs_to_many :admin_users, :join_table => :admin_users_admin_roles" }
      it { should contain "belongs_to :resource, :polymorphic => true" }
    end
    
    describe 'app/models/admin_user.rb' do
      subject { file('app/models/admin_user.rb') }
      
      it { should contain /class AdminUser < ActiveRecord::Base\n  rolify :role_cname => 'AdminRole'\n/ }
    end
    
    describe 'migration file' do
      subject { migration_file('db/migrate/rolify_create_admin_roles.rb') }
      
      it { should be_a_migration }
      it { should contain "create_table(:admin_roles)" }
      it { should contain "create_table(:admin_users_admin_roles, :id => false) do" }
    end
  end
  
  describe 'specifying namespaced User and Role class names' do
    before(:all) { arguments %w(Admin::Role Admin::User) }
    
    before { 
      capture(:stdout) {
        generator.create_file "app/models/admin/user.rb" do
<<-RUBY
module Admin
  class User < ActiveRecord::Base
    self.table_name_prefix = 'admin_'
  end
end
RUBY
        end
      }
      require File.join(destination_root, "app/models/admin/user.rb")
      run_generator
    }
    
    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }
      
      it { should exist }
      it { should contain "Rolify.configure(\"Admin::Role\") do |config|"}
      it { should contain "# config.use_dynamic_shortcuts" }
      it { should contain "# config.use_mongoid" }
    end
    
    describe 'app/models/admin/role.rb' do
      subject { file('app/models/admin/role.rb') }
      
      it { should exist }
      it { should contain "class Admin::Role < ActiveRecord::Base" }
      it { should contain "has_and_belongs_to_many :admin_users, :join_table => :admin_users_admin_roles" }
      it { should contain "belongs_to :resource, :polymorphic => true" }
    end
    
    describe 'app/models/admin/user.rb' do
      subject { file('app/models/admin/user.rb') }
      
      it { should contain /class User < ActiveRecord::Base\n  rolify :role_cname => 'Admin::Role'\n/ }
    end
    
    describe 'migration file' do
      subject { migration_file('db/migrate/rolify_create_admin_roles.rb') }
      
      it { should be_a_migration }
      it { should contain "create_table(:admin_roles)" }
      it { should contain "create_table(:admin_users_admin_roles, :id => false) do" }
    end
  end
  
  describe 'specifying ORM adapter' do 
    before(:all) { arguments [ "Role", "MongoUser", "--orm=mongoid" ] }
    
    before { 
      capture(:stdout) {
        generator.create_file "app/models/mongo_user.rb" do
<<-RUBY
class MongoUser
  include Mongoid::Document

  field :login, :type => String
end
RUBY
        end
      }
      require File.join(destination_root, "app/models/mongo_user.rb")
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
      it { should contain "has_and_belongs_to_many :mongo_users\n" }
      it { should contain "belongs_to :resource, :polymorphic => true" }
      it { should contain "field :name, :type => String" }
      it { should contain "  index({\n"
                          "      { :name => 1 },\n"
                          "      { :resource_type => 1 },\n"
                          "      { :resource_id => 1 }\n"
                          "    },\n"
                          "    { unique => true })"}
    end
    
    describe 'app/models/mongo_user.rb' do
      subject { file('app/models/mongo_user.rb') }
      it { should contain /class MongoUser\n  include Mongoid::Document\n  rolify\n/ }
    end
  end
  
  describe 'specifying namespaced User and Role class names and ORM adapter' do
    before(:all) { arguments %w(Admin::Role Admin::MongoUser --orm=mongoid) }
    
    before { 
      capture(:stdout) {
        generator.create_file "app/models/admin/mongo_user.rb" do
<<-RUBY
module Admin
  class MongoUser
    include Mongoid::Document
  end
end
RUBY
        end
      }
      require File.join(destination_root, "app/models/admin/mongo_user.rb")
      run_generator
    }
    
    describe 'config/initializers/rolify.rb' do
      subject { file('config/initializers/rolify.rb') }
      
      it { should exist }
      it { should contain "Rolify.configure(\"Admin::Role\") do |config|"}
      it { should contain "# config.use_dynamic_shortcuts" }
      it { should_not contain "# config.use_mongoid" }
    end
    
    describe 'app/models/admin/role.rb' do
      subject { file('app/models/admin/role.rb') }
      
      it { should exist }
      it { should contain "class Admin::Role" }
      it { should contain "has_and_belongs_to_many :admin_mongo_users" }
      it { should contain "belongs_to :resource, :polymorphic => true" }
    end
    
    describe 'app/models/admin/mongo_user.rb' do
      subject { file('app/models/admin/mongo_user.rb') }
      
      it { should contain /class MongoUser\n    include Mongoid::Document\n  rolify :role_cname => 'Admin::Role'\n/ }
    end
  end
end
