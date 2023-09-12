# frozen_string_literal: true

require 'rails'

module BulletmarkRepairer
  class Railtie < ::Rails::Railtie
    initializer 'bulletmark_repairer' do
      ActiveSupport.on_load(:action_controller) do
        require 'bullet'
        require 'bulletmark_repairer/monkey_patches/bullet/rack'
        ::Bullet.singleton_class.prepend BulletmarkRepairer::Bullet
        ::Bullet::Rack.prepend BulletmarkRepairer::Bullet::Rack
      end
      ActiveSupport.on_load(:active_record) do
        require 'bulletmark_repairer/monkey_patches/active_record/core'
        ::ActiveRecord::Core::ClassMethods.prepend BulletmarkRepairer::ActiveRecord::Core
      end
    end
  end
end
