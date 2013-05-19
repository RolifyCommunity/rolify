require 'rolify'
require 'rails'

module Rolify
  class Railtie < Rails::Railtie
    initializer 'rolify.initialize' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :extend, Rolify
      end
    end
  end
end