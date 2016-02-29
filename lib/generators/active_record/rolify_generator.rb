require 'rails/generators/active_record'
require 'active_support/core_ext'

module ActiveRecord
  module Generators
    class RolifyGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      argument :user_cname, :type => :string, :default => "User", :banner => "User"

      def ensure_user_class_defined
        unless user_class_defined?
          prompt_missing_user
          abort
        end
      end

      def generate_model
        invoke "active_record:model", [ name ], :migration => false
      end

      def inject_role_class
        if args[1]=="engine"
          if args[2]=="devise"
            require 'devise'
            require "#{ENGINE_ROOT}/config/initializers/devise.rb"
            require "#{ENGINE_ROOT}/app/models/#{user_cname.downcase}.rb"
          else
            require "#{ENGINE_ROOT}/app/models/#{user_cname.downcase}.rb"
          end
        end

        inject_into_class(model_path, class_name, model_content)
      end

      def copy_rolify_migration
        migration_template "migration.rb", "db/migrate/rolify_create_#{table_name}.rb"
      end

      private

      def join_table
        user_class.table_name + "_" + table_name
      end

      def user_reference
        user_cname.demodulize.underscore
      end

      def role_reference
        class_name.demodulize.underscore
      end

      def model_path
        File.join("app", "models", "#{file_path}.rb")
      end

      def model_content
        content = <<RUBY
  has_and_belongs_to_many :%{user_cname}, :join_table => :%{join_table}

  belongs_to :resource,
             :polymorphic => true,
             :optional => true

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  scopify
RUBY
        content % { :user_cname => user_class.table_name, :join_table => "#{user_cname.constantize.table_name}_#{table_name}"}
      end

      def user_class
        user_cname.constantize
      end

      def user_class_defined?
        user_class
        true
      rescue NameError => ex
        if ex.missing_name == user_cname
          false
        else
          raise ex
        end
      end

      def prompt_missing_user
        puts <<MSG
Rolify expected a model named #{user_cname} to be defined but could not find one.
Please ensure that this model exists and is not mis-spelled and re-run the generator.
MSG
      end

    end
  end
end
