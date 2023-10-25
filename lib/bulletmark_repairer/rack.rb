# frozen_string_literal: true

module BulletmarkRepairer
  class Rack
    def initialize(app)
      @app = app
    end

    def call(env)
      Thread.current[:bulletmark_repaier_loaded_associations] = Hash.new do |hash, key|
        hash[key] = { includes: Set.new, eager_load: Set.new, preload: Set.new }
      end
      @app.call(env)
    ensure
      begin
        if Thread.current[:bullet_notification_collector].notifications_present?
          BulletmarkRepairer::Patcher.execute(
            notifications: Thread.current[:bullet_notification_collector],
            controller: env['action_dispatch.request.parameters']['controller'],
            action: env['action_dispatch.request.parameters']['action'],
            loaded_associations: Thread.current[:bulletmark_repaier_loaded_associations]
          )
        end
      rescue StandardError => e
        raise e if BulletmarkRepairer.config.debug?
      end
      Thread.current[:bulletmark_repaier_loaded_associations].clear
    end
  end
end
