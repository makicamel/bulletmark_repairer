# frozen_string_literal: true

require 'rails'

module BulletmarkRepairer
  class Thread
    class << self
      def current(key)
        touch(key)
      end

      def memorize_associations(name:, method_type:, args:)
        current(:loaded_associations)[name][method_type].add(args)
      end

      def memorize_instance_variable_name(name:, value:)
        return unless value.is_a?(::ActiveRecord::Relation)

        current(:loaded_instance_variables).add("@#{name}")
      end

      def instance_variable_name?(name)
        current(:loaded_instance_variables).include?(name)
      end

      def clear
        ::Thread.current[:bulletmark_repairer] = nil
      end

      private

      # @param key [Symbol] :loaded_associations or :loaded_instance_variables
      def touch(key)
        ::Thread.current[:bulletmark_repairer] ||= {}
        if key == :loaded_associations
          ::Thread.current[:bulletmark_repairer][:loaded_associations] ||= Hash.new do |hash, key|
            hash[key] = { includes: Set.new, eager_load: Set.new, preload: Set.new }
          end
        else
          ::Thread.current[:bulletmark_repairer][:loaded_instance_variables] ||= Set.new
        end
      end
    end
  end
end
