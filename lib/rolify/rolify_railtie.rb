module Rolify
  class RoleRailtie < ::Rails::Railtie
    initializer "instantiate roles methods" do
      ActiveSupport.on_load :active_record do
        Rolify.user_cname.load_dynamic_methods if defined? Rails.server
      end
    end
  end
end