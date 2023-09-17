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
        BulletmarkRepairer.action = nil
        super
      ensure
        if BulletmarkRepairer.notifications.present?
          controller_corrector = Pathname.new(__FILE__).sub('/monkey_patches/bullet/rack.rb', '/controller_corrector.rb')
          default_corrector = Pathname.new(__FILE__).sub('/monkey_patches/bullet/rack.rb', '/corrector.rb')
          tracer = BulletmarkRepairer.tracers.last

          file_name = tracer&.scan(%r{\A([./\w]+):\d+:in `[\w\s]+'\z})&.flatten&.first
          if file_name.start_with?("#{Rails.root}/app/views")
            BulletmarkRepairer.action = env['action_dispatch.request.parameters']['action'].to_sym
            controller_file = "#{Rails.root}/app/controllers/#{env['action_dispatch.request.parameters']['controller']}_controller.rb"
            Parser::Runner::RubyRewrite.go(%W[-l #{controller_corrector} -m #{controller_file}])
          else
            Parser::Runner::RubyRewrite.go(%W[-l #{default_corrector} -m #{file_name}])
          end
        end
      end
    end
  end
end
