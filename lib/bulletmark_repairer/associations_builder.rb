# frozen_string_literal: true

require 'forwardable'

module BulletmarkRepairer
  class AssociationsBuilder
    def build(marker)
      return if marker.skip?

      if associations[marker.index]
        associations[marker.index].add(marker)
      else
        associations[marker.index] = Associations.new(
          marker,
          @application_associations,
          @loaded_associations
        )
      end
    end

    def associations
      @associations ||= {}
    end

    private

    def initialize(loaded_associations)
      @application_associations = BulletmarkRepairer::ApplicationAssociations.new
      @loaded_associations = BulletmarkRepairer::LoadedAssociations.new(loaded_associations)
    end
  end

  class Associations
    extend Forwardable

    def_delegators :@marker, :file_name, :instance_variable_name

    def add(child_marker)
      build_associations!(marker: child_marker, associations: @marker.associations, parent_keys: [:base])
    end

    def corrector(dir)
      BulletmarkRepairer::CorrectorBuilder.new(
        dir: dir,
        marker: @marker,
        associations: @associations
      ).execute
    end

    private

    def initialize(marker, application_associations, loaded_associations)
      @marker = marker
      @application_associations = application_associations
      @loaded_associations = loaded_associations
      key = @loaded_associations.key(marker.base_class)
      @associations = { base: key ? { key => marker.associations } : marker.associations }
    end

    # @return [Hash, nil]
    def build_associations!(marker:, associations:, parent_keys:)
      key = formed_key(marker: marker, associations: associations)
      if key
        modify_value(key: key, marker: marker, parent_keys: parent_keys)
      else
        new_parent_keys = parent_keys
        new_parent_keys.append(0) if associations.is_a?(Array)
        associations.each do |association_values|
          next unless association_values.is_a?(Hash)

          association_values.each do |key, value|
            values = value.is_a?(Array) ? value : [value]
            build_associations!(marker: marker, associations: { key => values }, parent_keys: new_parent_keys)
          end
        end
      end
    end

    # @return [Symbol, nil]
    def formed_key(marker:, associations:)
      case associations
      when Hash
        @application_associations.key(marker.base_class, @marker.base_class, associations.keys) ||
          @application_associations.key(marker.base_class, @marker.base_class, associations.values.flatten)
      when Array
        @application_associations.key(marker.base_class, @marker.base_class, associations)
      else # Symbol, String
        @application_associations.key(marker.base_class, @marker.base_class, [associations])
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
