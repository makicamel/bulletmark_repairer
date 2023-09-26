# frozen_string_literal: true

module BulletmarkRepairer
  class Rack
    def initialize(app)
      @app = app
    end

    def call(env)
      BulletmarkRepairer.tracers.clear
      @app.call(env)
    ensure
      begin
        if Thread.current[:bullet_notification_collector].notifications_present?
          BulletmarkRepairer::Pathcer.execute(
            notifications: Thread.current[:bullet_notification_collector],
            controller: env['action_dispatch.request.parameters']['controller'],
            action: env['action_dispatch.request.parameters']['action']
          )
        end
      rescue StandardError => e
        # TODO: handle error
        raise e
      end
    end
  end
end
