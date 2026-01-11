# frozen_string_literal: true

module BulletmarkRepairer
  class LoadedAssociations
    attr_reader :associations

    def key(target_klass_name)
      key = target_klass_name.underscore

      result = []
      @associations.each_value do |all_associations|
        all_associations.each_value do |associations|
          # TODO: recurrent check
          associations.each do |values|
            values.flatten.each do |value|
              result.append search_key(key, value)
            end
          end
        end
      end
      result = result.flatten.compact.uniq.presence
      build_keys(result)
    end

    private

    def search_key(key, value)
      case value
      when Hash
        search_key(key, value.keys) || search_key(key, value.values)
      when Array
        value.map { |v| search_key(key, v) }
      else
        if key.pluralize.to_sym == value
          key.pluralize.to_sym
        elsif key.singularize.to_sym == value
          key.singularize.to_sym
        end
      end
    end

    def build_keys(keys)
      return unless keys

      if keys.size == 1
        keys.first
      else
        { keys.first => keys.last }
      end
    end

    def initialize(original_associations)
      @associations = Hash.new { |h, k| h[k] = {} }
      original_associations.each do |base_class, all_associations|
        all_associations.each do |key, associations|
          @associations[base_class][key] = associations.to_a
        end
      end
    end
  end
end
