# frozen_string_literal: true

module BulletmarkRepairer
  class Configration
    attr_accessor :skip_file_list, :logger
    attr_writer :development

    def initialize
      @development = false
      @skip_file_list = []
      @logger = Logger.new("#{Rails.root}/log/bulletmark_repairer.log")
    end

    def development?
      @development
    end
  end

  class << self
    def configure
      yield config
    end

    def config
      @config ||= Configration.new
    end
  end
end
