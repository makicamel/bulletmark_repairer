# frozen_string_literal: true

require 'rails'

module BulletmarkRepairer
  class Thread
    class << self
      def current
        touch
      end

      def add(name:, method_type:, args:)
        touch
        ::Thread.current[:bulletmark_repaier_loaded_associations][name][method_type].add(args)
      end

      def clear
        ::Thread.current[:bulletmark_repaier_loaded_associations] = nil
      end

      private

      def touch
        ::Thread.current[:bulletmark_repaier_loaded_associations] ||= Hash.new do |hash, key|
          hash[key] = { includes: Set.new, eager_load: Set.new, preload: Set.new }
        end
      end
    end
  end
end
