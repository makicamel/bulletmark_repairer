# frozen_string_literal: true

module BulletmarkRepairer
  class Rack
    def initialize(app)
      @app = app
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      BulletmarkRepairer.reset_associations
      @app.call(env)
    ensure
      begin
        if Thread.current[:bullet_notification_collector].notifications_present?
          BulletmarkRepairer::Patcher.execute(
            notifications: Thread.current[:bullet_notification_collector],
            controller: env['action_dispatch.request.parameters']['controller'],
            action: env['action_dispatch.request.parameters']['action']
          )
        end
      rescue StandardError => e
        raise e if BulletmarkRepairer.config.debug?
      end
    end
  end
end
