# frozen_string_literal: true

module BulletmarkRepairer
  def self.markers
    @markers ||= []
  end

  def self.markers=(markers)
    @markers = markers
  end

  def self.tracers
    @tracers ||= []
  end

  def self.action
    @action ||= nil
  end

  def self.action=(action)
    @action = action
  end
end
