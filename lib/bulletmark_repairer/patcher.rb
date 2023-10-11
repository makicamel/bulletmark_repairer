# frozen_string_literal: true

require 'fileutils'
require 'securerandom'
require 'parser/runner/ruby_rewrite'

module BulletmarkRepairer
  class Patcher
    def self.execute(notifications:, controller:, action:)
      new(notifications: notifications, controller: controller, action: action).execute
    end

    def execute
      @markers.each do |_base_class, marker|
        @associations_builder.build(marker)
      end
      @associations_builder.associations.each do |_index, associations|
        path = "#{Rails.root}/tmp/#{SecureRandom.hex(10)}"
        FileUtils.mkdir(path)
        Parser::Runner::RubyRewrite.go(%W[-l #{associations.corrector(path)} -m #{associations.file_name}])
        FileUtils.rm_r(path)
      end
    end

    private

    def initialize(notifications:, controller:, action:)
      @markers = Markers.new(notifications, controller: controller, action: action)
      @associations_builder = BulletmarkRepairer::AssociationsBuilder.new
    end
  end
end
