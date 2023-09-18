# frozen_string_literal: true

module BulletmarkRepairer
  module Bullet
    def end_request
      BulletmarkRepairer.notifications = Thread.current[:bullet_notification_collector].collection.to_a.deep_dup
      super
    end

    module Rack
      def call(env)
        BulletmarkRepairer.notifications.clear
        BulletmarkRepairer.tracers.clear
        BulletmarkRepairer.action = nil
        super
      ensure
        if BulletmarkRepairer.notifications.present?
          BulletmarkRepairer::Pathcer.execute(
            controller: env['action_dispatch.request.parameters']['controller'],
            action: env['action_dispatch.request.parameters']['action'].to_sym
          )
        end
      end
    end
  end
end
