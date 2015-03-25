require "rolify/configure"

module Rolify
  module Dynamic
    def load_dynamic_methods
      self.role_class.all.each do |r|
        define_dynamic_method(r.name, r.resource)
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