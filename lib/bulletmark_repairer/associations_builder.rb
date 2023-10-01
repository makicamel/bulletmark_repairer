# frozen_string_literal: true

require 'forwardable'

module BulletmarkRepairer
  class AssociationsBuilder
    def build(marker)
      if associations[marker.index]
        # TODO
      else
        associations[marker.index] = Associations.new(marker)
      end
    end

    def associations
      @associations ||= {}
    end
  end

  class Associations
    extend Forwardable

    def_delegators :@marker, :file_name

    def instance_variable_name
      @marker.instance_variable_name_in_view
    end

    def corrector(dir)
      BulletmarkRepairer::CorrectorBuilder.new(
        dir:,
        marker: @marker,
        associations: @associations
      ).execute
    end

    private

    def initialize(marker)
      @marker = marker
      @associations = {}
      if marker.direct_associations == marker.associations
        @associations[:base] = marker.associations
      else
        build_associations!(marker:, associations: marker.associations, parent_keys: [:base])
      end
    end

    # @return [Hash, nil]
    def build_associations!(marker:, associations:, parent_keys:)
      key = formed_key(marker:, associations:)
      if key
        modify_value(key:, marker:, parent_keys:)
      else
        new_parent_keys = parent_keys
        new_parent_keys.append(0) if associations.is_a?(Array)
        associations.each do |association_values|
          next unless association_values.is_a?(Hash)

          association_values.each do |key, value|
            values = value.is_a?(Array) ? value : [value]
            build_associations!(marker:, associations: { key => values }, parent_keys: new_parent_keys)
          end
        end
      end
    end

    # @return [Symbol, nil]
    def formed_key(marker:, associations:)
      key = marker.base_class.underscore
      case associations
      when Hash
        if key.singularize.to_sym == associations.keys.first || key.singularize.to_sym.in?(associations.values.flatten)
          key.singularize.to_sym
        else
          key.pluralize.to_sym == associations.keys.first || key.pluralize.to_sym.in?(associations.values.flatten) ? key.pluralize.to_sym : nil
        end
      when Array
        if key.singularize.to_sym.in?(associations)
          key.singularize.to_sym
        else
          key.pluralize.to_sym.in?(associations) ? key.pluralize.to_sym : nil
        end
      else # Symbol, String
        if key.singularize.to_sym == associations
          key.singularize.to_sym
        else
          key.pluralize.to_sym == associations ? key.pluralize.to_sym : nil
        end
      end
    end

    def modify_value(key:, marker:, parent_keys:)
      case @associations.dig(*parent_keys)
      when Hash
        # when key is in value
        if @associations.dig(*parent_keys)[key].nil?
          last_key = @associations.dig(*parent_keys).keys.first
          if @associations.dig(*parent_keys)[last_key].is_a?(Array)
            @associations.dig(*parent_keys)[last_key].delete(key)
            @associations.dig(*parent_keys)[last_key].append(key => marker.associations)
          else
            @associations.dig(*parent_keys)[last_key] = { key => marker.associations }
          end
        # when key is in key
        else
          value = if @associations.dig(*parent_keys)[key].is_a?(Array)
                    @associations.dig(*parent_keys)[key] + marker.associations
                  else
                    [@associations.dig(*parent_keys)[key], *marker.associations]
                  end
          @associations.dig(*parent_keys)[key] = value
        end
      when Array
        @associations.dig(*parent_keys).delete(key)
        @associations.dig(*parent_keys).append(key => marker.associations)
      else # Symbol, String
        last_key = parent_keys.slice!(-1)
        @associations.dig(*parent_keys)[last_key] = { key => marker.associations }
      end
    end
  end
end
