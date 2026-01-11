# frozen_string_literal: true

require 'fileutils'
require 'securerandom'
require 'parser/runner/ruby_rewrite'

module BulletmarkRepairer
  class Patcher
    def self.execute(notifications:, controller:, action:, loaded_associations:)
      new(notifications: notifications, controller: controller, action: action, loaded_associations: loaded_associations).execute
    end

    def execute
      @markers.each_value do |marker|
        @associations_builder.build(marker)
      end
      @associations_builder.associations.each_value do |associations|
        path = "#{Rails.root}/tmp/#{SecureRandom.hex(10)}"
        FileUtils.mkdir(path)
        Parser::Runner::RubyRewrite.go(%W[-l #{associations.corrector(path)} -m #{associations.file_name}])
        FileUtils.rm_r(path)
      end
    end

    private

    def initialize(notifications:, controller:, action:, loaded_associations:)
      @markers = Markers.new(notifications, controller: controller, action: action)
      @associations_builder = BulletmarkRepairer::AssociationsBuilder.new(loaded_associations)
    end
  end
end
