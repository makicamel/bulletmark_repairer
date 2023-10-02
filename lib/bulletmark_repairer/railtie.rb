# frozen_string_literal: true

require 'rails'

module BulletmarkRepairer
  class Railtie < ::Rails::Railtie
    initializer 'bulletmark_repairer' do |app|
      require 'bullet'
      require 'bulletmark_repairer/rack'
      app.middleware.insert_after Bullet::Rack, BulletmarkRepairer::Rack
    end
  end
end
