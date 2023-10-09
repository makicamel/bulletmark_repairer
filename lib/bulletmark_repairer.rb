# frozen_string_literal: true

require 'bulletmark_repairer/version'
require 'bulletmark_repairer/railtie' if ENV['REPAIR']
require 'bulletmark_repairer/bulletmark_repairer'
require 'bulletmark_repairer/associations_builder'
require 'bulletmark_repairer/corrector_builder'
require 'bulletmark_repairer/markers'
require 'bulletmark_repairer/patcher'

module BulletmarkRepairer
  class Error < StandardError; end
  # Your code goes here...
end
