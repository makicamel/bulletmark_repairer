# frozen_string_literal: true

module BulletmarkRepairer
  def self.notifications
    @notifications ||= []
  end

  def self.notifications=(notifications)
    @notifications = notifications
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
