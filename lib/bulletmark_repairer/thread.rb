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

      # TODO: Memorize methods with class
      def memorize_methods(method_name:, value:)
        return unless value.is_a?(::ActiveRecord::Associations::CollectionProxy) || value.is_a?(::ActiveRecord::Relation)

        current(:loaded_methods).add(method_name)
      end

      def correctable_method?(method_name)
        current(:loaded_methods).include?(method_name)
      end

      def clear
        ::Thread.current[:bulletmark_repairer] = nil
      end

      private

      def touch(key)
        ::Thread.current[:bulletmark_repairer] ||= {}
        case key
        when :loaded_associations
          ::Thread.current[:bulletmark_repairer][:loaded_associations] ||= Hash.new do |hash, key|
            hash[key] = { includes: Set.new, eager_load: Set.new, preload: Set.new }
          end
        when :loaded_instance_variables
          ::Thread.current[:bulletmark_repairer][:loaded_instance_variables] ||= Set.new
        when :loaded_methods
          ::Thread.current[:bulletmark_repairer][:loaded_methods] ||= Set.new
        end
      end
    end
  end
end
