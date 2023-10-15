# frozen_string_literal: true

module BulletmarkRepairer
  class ApplicationAssociations
    def key(target_klass_name, base_klass_name, candidates)
      key = target_klass_name.underscore
      matched_candidates = candidates - (candidates - @associations[base_klass_name][:associations])
      if key.pluralize.to_sym.in?(candidates)
        key.pluralize.to_sym
      elsif key.singularize.to_sym.in?(candidates)
        key.singularize.to_sym
      else
        index = matched_candidates.index do |matched_candidate|
          key.pluralize.to_sym.in?(@associations[base_klass_name][:aliases][matched_candidate]) ||
            key.singularize.to_sym.in?(@associations[base_klass_name][:aliases][matched_candidate])
        end
        matched_candidates[index] if index
      end
    end

    private

    def initialize
      blank_array_hash = Hash.new { |hash, key| hash[key] = [] }
      @associations = Hash.new { |hash, key| hash[key] = { associations: [], aliases: blank_array_hash } }
      ::ActiveRecord::Base
        .descendants
        .select { |klass| klass.respond_to?(:reflect_on_all_associations) }
        .each do |klass|
          klass.reflect_on_all_associations.each do |association_instance|
            association = association_instance.respond_to?(:delegate_reflection) ? association_instance.delegate_reflection : association_instance
            klass_name = association.active_record.name
            association_name = association.name
            @associations[klass_name][:associations] |= [association_name]
            next unless association.options[:source]

            alias_name = association.instance_of?(::ActiveRecord::Reflection::HasManyReflection) ? association.options[:source].to_s.pluralize.to_sym : association.options[:source]
            @associations[klass_name][:aliases][association.name] |= [alias_name]
          end
        end
    end
  end
end
