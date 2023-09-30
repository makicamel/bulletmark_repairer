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
        build_associations!(marker:, associations: marker.associations, parent_key: :base)
      end
    end

    # @return [Hash, nil]
    def build_associations!(marker:, associations:, parent_key:)
      key = formed_key(marker:, associations:)
      return unless key

      modify_value(key:, marker:, parent_key:)
    end

    # @return [Symbol, nil]
    def formed_key(marker:, associations:)
      key = marker.base_class.underscore
      case associations
      when Hash
        if key.singularize.to_sym == associations.keys.first
          key.singularize.to_sym
        else
          key.pluralize.to_sym == associations.keys.first ? key.pluralize.to_sym : nil
        end
      when Array
        if key.singularize.to_sym.in?(associations)
          key.singularize.to_sym
        else
          key.pluralize.to_sym.in?(associations) ? key.pluralize.to_sym : nil
        end
      end
    end

    def modify_value(key:, marker:, parent_key:)
      case @associations[parent_key]
      when Hash
        value = if @associations[parent_key][key].is_a?(Array)
                  @associations[parent_key][key] + marker.associations
                else
                  [@associations[parent_key][key], *marker.associations]
                end
        @associations[parent_key][key] = value
      when Array
        @associations[parent_key].delete(key)
        @associations[parent_key].append(key => marker.associations)
      else # Symbol, String
        @associations[parent_key] = { key => marker.associations }
      end
    end
  end
end
