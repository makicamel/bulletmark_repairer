# frozen_string_literal: true

require 'parser/runner/ruby_rewrite'

module BulletmarkRepairer
  class Pathcer
    def self.execute(notifications:, controller:, action:)
      new(notifications:, controller:, action:).execute
    end

    def execute
      @markers.each do |_base_class, marker|
        BulletmarkRepairer::AssociationsBuilder.build(marker)
      end
      BulletmarkRepairer::AssociationsBuilder.associations.each do |index, associations|
        associations.instance_variable_get(:@marker).patching!
        BulletmarkRepairer::AssociationsBuilder.patching_index = index
        Parser::Runner::RubyRewrite.go(%W[-l #{associations.corrector} -m #{associations.file_name}])
        BulletmarkRepairer::AssociationsBuilder.patching_index = nil
        associations.instance_variable_get(:@marker).patched!
      end
    end

    private

    def initialize(notifications:, controller:, action:)
      @markers = Markers.new(notifications)
      BulletmarkRepairer.controller = controller
      BulletmarkRepairer.action = action
    end
  end
end
