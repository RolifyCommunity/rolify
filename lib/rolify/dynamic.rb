require "rolify/configure"

module Rolify
  module Dynamic
    def define_dynamic_method(role_name, resource)
      class_eval do
        if self.adapter.where_strict(self.role_class, name: role_name).exists?
          if !method_defined?("is_#{role_name}?".to_sym)
            define_method("is_#{role_name}?".to_sym) do
              has_role?("#{role_name}")
            end
          end
        else
          undef_method("is_#{role_name}?".to_sym) if method_defined?("is_#{role_name}?".to_sym)
        end

        if resource && self.adapter.where_strict(self.role_class, name: role_name, resource: resource).exists?
          if !method_defined?("is_#{role_name}_of?".to_sym)
            define_method("is_#{role_name}_of?".to_sym) do |arg|
              has_role?("#{role_name}", arg)
            end
          end
        else
          undef_method("is_#{role_name}_of?".to_sym) if method_defined?("is_#{role_name}_of?".to_sym)
        end
      end
    end
  end
end
