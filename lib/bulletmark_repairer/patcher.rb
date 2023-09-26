# frozen_string_literal: true

require 'fileutils'
require 'securerandom'
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
      BulletmarkRepairer::AssociationsBuilder.associations.each do |_index, associations|
        path = "#{Rails.root}/tmp/#{SecureRandom.hex(10)}"
        FileUtils.mkdir(path)
        Parser::Runner::RubyRewrite.go(%W[-l #{associations.corrector(path)} -m #{associations.file_name}])
        FileUtils.rm_r(path)
      end
    end

    private

    def initialize(notifications:, controller:, action:)
      @markers = Markers.new(notifications, controller:, action:)
    end
  end
end
