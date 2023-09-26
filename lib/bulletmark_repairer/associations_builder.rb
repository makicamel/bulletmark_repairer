# frozen_string_literal: true

require 'forwardable'

module BulletmarkRepairer
  class AssociationsBuilder
    class << self
      def associations
        @associations ||= {}
      end

      def build(marker)
        if associations[marker.index]
          # TODO
        else
          associations[marker.index] = Associations.new(marker)
        end
      end
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
      if marker.direct_associations == marker.associations
        @associations = marker.associations
      else
        key = marker.base_class.underscore
        @associations = if key.singularize.in?(marker.associations)
                          { key.singularize.to_sym => marker.associations }
                        else
                          { key.pluralize.to_sym => marker.associations }
                        end
      end
    end
  end
end
