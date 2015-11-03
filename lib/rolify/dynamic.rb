require "rolify/configure"

module Rolify
  module Dynamic
    def load_dynamic_methods
      if ENV['ADAPTER'] == 'active_record'
        # supported Rails version >= 3.2 with AR should use find_each, since use of .all.each is deprecated
        self.role_class.group("name, resource_type").includes(:resource).find_each do |r|
          define_dynamic_method(r.name, r.resource)
        end
      else
        # for compatibility with MongoidDB and older Rails AR - does not support polymorphic includes
        self.role_class.all.each do |r|
          define_dynamic_method(r.name, r.resource)
        end
      end
    end

    def define_dynamic_method(role_name, resource)
      class_eval do 
        define_method("is_#{role_name}?".to_sym) do
          has_role?("#{role_name}")
        end if !method_defined?("is_#{role_name}?".to_sym)

        define_method("is_#{role_name}_of?".to_sym) do |arg|
          has_role?("#{role_name}", arg)
        end if !method_defined?("is_#{role_name}_of?".to_sym) && resource
      end
    end
  end
end
