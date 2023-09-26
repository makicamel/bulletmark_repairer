# frozen_string_literal: true

require 'rails'

module BulletmarkRepairer
  class Railtie < ::Rails::Railtie
    initializer 'bulletmark_repairer' do |app|
      require 'bullet'
      require 'bulletmark_repairer/rack'
      app.middleware.insert_after Bullet::Rack, BulletmarkRepairer::Rack

      ActiveSupport.on_load(:active_record) do
        require 'bulletmark_repairer/monkey_patches/active_record/core'
        ::ActiveRecord::Core::ClassMethods.prepend BulletmarkRepairer::ActiveRecord::Core
      end
    end
  end
end
