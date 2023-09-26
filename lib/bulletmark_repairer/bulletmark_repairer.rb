# frozen_string_literal: true

module BulletmarkRepairer
  def self.tracers
    @tracers ||= Hash.new { |hash, key| hash[key] = [] }
  end
end
