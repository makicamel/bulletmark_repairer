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

  def self.target_method
    @target_method ||= nil
  end

  def self.target_method=(target_method)
    @target_method = target_method
  end
end
