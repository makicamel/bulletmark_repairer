# frozen_string_literal: true

module BulletmarkRepairer
  def self.markers=(notifications)
    @markers = Markers.new(notifications)
  end

  def self.markers
    @markers
  end

  def self.tracers
    @tracers ||= Hash.new { |hash, key| hash[key] = [] }
  end

  def self.controller_file
    @controller_file ||= "#{Rails.root}/app/controllers/#{@controller}_controller.rb"
  end

  def self.controller=(controller)
    @controller = controller
  end

  def self.action
    @action ||= nil
  end

  def self.action=(action)
    @action = action
  end
end
