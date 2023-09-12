# frozen_string_literal: true

require 'parser/runner/ruby_rewrite'

module BulletmarkRepairer
  module Bullet
    def end_request
      BulletmarkRepairer.notifications = Thread.current[:bullet_notification_collector].collection.to_a.deep_dup
      super
    end

    module Rack
      def call(...)
        BulletmarkRepairer.notifications.clear
        BulletmarkRepairer.tracers.clear
        super
      ensure
        if BulletmarkRepairer.notifications.present?
          tracer = BulletmarkRepairer.tracers.last

          file_name = tracer&.scan(%r{\A([./\w]+):\d+:in `[\w\s]+'\z})&.flatten&.first
          Parser::Runner::RubyRewrite.go(%W[-l lib/bulletmark_repairer/corrector.rb -m #{file_name}]) if file_name
        end
      end
    end
  end
end
