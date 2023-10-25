# frozen_string_literal: true

require 'bulletmark_repairer/version'
require 'bulletmark_repairer/railtie' if ENV['REPAIR']
require 'bulletmark_repairer/application_associations'
require 'bulletmark_repairer/associations_builder'
require 'bulletmark_repairer/configuration'
require 'bulletmark_repairer/corrector_builder'
require 'bulletmark_repairer/loaded_associations'
require 'bulletmark_repairer/markers'
require 'bulletmark_repairer/patcher'

module BulletmarkRepairer
  class Error < StandardError; end
end
