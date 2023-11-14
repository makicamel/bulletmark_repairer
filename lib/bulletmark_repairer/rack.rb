# frozen_string_literal: true

module BulletmarkRepairer
  class Rack
    def initialize(app)
      @app = app
    end

    def call(env)
      trace_point = TracePoint.trace(:return) do |tp|
        BulletmarkRepairer::Thread.memorize_methods(
          method_name: tp.method_id,
          value: tp.return_value
        )
      end
      @app.call(env)
    ensure
      trace_point.disable
      begin
        if ::Thread.current[:bullet_notification_collector].notifications_present?
          BulletmarkRepairer::Patcher.execute(
            notifications: ::Thread.current[:bullet_notification_collector],
            controller: env['action_dispatch.request.parameters']['controller'],
            action: env['action_dispatch.request.parameters']['action'],
            loaded_associations: BulletmarkRepairer::Thread.current(:loaded_associations)
          )
        end
      rescue StandardError => e
        raise e if BulletmarkRepairer.config.debug?
      end
      BulletmarkRepairer::Thread.clear
    end
  end
end
