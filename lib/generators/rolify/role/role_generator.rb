require 'rails/generators/migration'

module Rolify
  module Generators
    class RoleGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('../templates', __FILE__)
      argument :role_cname, :type => :string, :default => "Role"
      argument :user_cname, :type => :string, :default => "User"
      argument :orm_adapter, :type => :string, :default => "active_record"
      class_option :dynamic_shortcuts, :type => :boolean, :default => false

      desc "Generates a model with the given NAME and a migration file."

      def generate_role
        template "role.rb", "app/models/#{role_cname.downcase}.rb"
        inject_into_class(model_path, user_cname.camelize) do
          " rolify\n"
        end
      end

      def copy_role_file
        template "initializer.rb", "config/initializers/rolify.rb"
        migration_template "migration.rb", "db/migrate/rolify_create_#{role_cname.tableize}"
      end

      def model_path
        File.join("app", "models", "#{user_cname.underscore}.rb")
      end
      
      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end
    end
  end
end
