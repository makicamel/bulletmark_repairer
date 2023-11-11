# frozen_string_literal: true

require 'rails'

module BulletmarkRepairer
  class Railtie < ::Rails::Railtie
    initializer 'bulletmark_repairer' do |app|
      require 'bullet'
      require 'bulletmark_repairer/rack'
      app.middleware.insert_after Bullet::Rack, BulletmarkRepairer::Rack
    end

    ActiveSupport.on_load(:active_record) do
      require 'bulletmark_repairer/monkey_patches/active_record/query_method'
      ::ActiveRecord::Relation.prepend(BulletmarkRepairer::ActiveRecord::QueryMethod)
    end
    ActiveSupport.on_load(:action_view) do
      require 'bulletmark_repairer/monkey_patches/action_view/base'
      ::ActionView::Base.prepend(BulletmarkRepairer::ActionView::Base)
    end
  end
end
