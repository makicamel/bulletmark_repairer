# frozen_string_literal: true

require 'parser/runner/ruby_rewrite'

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
        super
      ensure
        if BulletmarkRepairer.notifications.present?
          tracer = BulletmarkRepairer.tracers.last

          file_name = tracer&.scan(%r{\A([./\w]+):\d+:in `[\w\s]+'\z})&.flatten&.first
          if file_name.start_with?("#{Rails.root}/app/views")
            BulletmarkRepairer.target_method = env['action_dispatch.request.parameters']['action'].to_sym
            controller_file = "#{Rails.root}/app/controllers/#{env['action_dispatch.request.parameters']['controller']}_controller.rb"
            Parser::Runner::RubyRewrite.go(%W[-l lib/bulletmark_repairer/controller_corrector.rb -m #{controller_file}])
          else
            Parser::Runner::RubyRewrite.go(%W[-l lib/bulletmark_repairer/corrector.rb -m #{file_name}])
          end
        end
      end
    end
  end
end
