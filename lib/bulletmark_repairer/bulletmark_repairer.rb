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

  def self.action
    @action ||= nil
  end

  def self.action=(action)
    @action = action
  end
end
