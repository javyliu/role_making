require 'role_making'
#require 'rails'

module RoleMaking
  class Railtie < ::Rails::Railtie
    initializer 'rolify.initialize' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :extend, RoleMaking
      end
    end
  end
end
