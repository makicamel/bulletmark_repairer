# frozen_string_literal: true

module BulletmarkRepairer
  class Configration
    attr_writer :development

    def initialize
      @development = false
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
