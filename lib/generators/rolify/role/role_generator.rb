require 'rails/generators/migration'

module Rolify
  module Generators
    class RoleGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('../templates', __FILE__)
      argument :role_cname, :type => :string, :default => "Role"
      argument :user_cname, :type => :string, :default => "User"
      class_option :dynamic_shortcuts, :type => :boolean, :default => false

      desc "Generates a model with the given NAME and a migration file."

      def generate_role
        template "role.rb", "app/models/#{role_cname.downcase}.rb"
        inject_into_class(model_path, user_cname.camelize) do
          "  include Rolify::Roles\n" + 
          "  #{'# ' if !options[:dynamic_shortcuts]}extend Rolify::Dynamic\n" + 
          "  has_and_belongs_to_many :roles#{", :class_name => \"" + role_cname.camelize + "\"" if role_cname != "Role"}, :join_table => :#{user_cname.tableize + "_" + role_cname.tableize}\n"
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
      
      def show_readme
        readme "README" if behavior == :invoke
      end
    end
  end
end
