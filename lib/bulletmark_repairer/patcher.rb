# frozen_string_literal: true

require 'parser/runner/ruby_rewrite'

module BulletmarkRepairer
  class Pathcer
    def self.execute(controller:, action:)
      new(controller:, action:).execute
    end

    def execute
      BulletmarkRepairer.markers.each do |_base_class, marker|
        marker.patching!
        if marker.n_plus_one_in_view?
          Parser::Runner::RubyRewrite.go(%W[-l #{controller_corrector} -m #{controller_file}])
        else
          Parser::Runner::RubyRewrite.go(%W[-l #{default_corrector} -m #{marker.file_name}])
        end
        marker.patched!
      end
    end

    private

    def initialize(controller:, action:)
      @controller = controller
      BulletmarkRepairer.action = action
    end

    def controller_file
      @controller_file ||= "#{Rails.root}/app/controllers/#{@controller}_controller.rb"
    end

    def controller_corrector
      @controller_corrector ||= Pathname.new(__FILE__).sub('/patcher.rb', '/controller_corrector.rb')
    end

    def default_corrector
      @default_corrector ||= Pathname.new(__FILE__).sub('/patcher.rb', '/corrector.rb')
    end
  end
end
