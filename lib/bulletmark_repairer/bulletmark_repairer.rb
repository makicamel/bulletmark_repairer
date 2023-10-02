# frozen_string_literal: true

module BulletmarkRepairer
  def self.associations
    return @associations if @associations.present?

    @associations = Hash.new { |hash, k| hash[k] = [] }
    ::ActiveRecord::Base
      .descendants
      .select { |klass| klass.respond_to?(:reflect_on_all_associations) }
      .each do |klass|
        klass.reflect_on_all_associations.each do |association_instance|
          association = if association_instance.instance_of?(ActiveRecord::Reflection::ThroughReflection)
                          association_instance.__send__(:delegate_reflection)
                        else
                          association_instance
                        end
          klass_name = association.active_record.name
          association_name = association.name
          @associations[klass_name] |= [association_name]
        end
      end
    @associations
  end

  def self.reset_associations
    @associations = nil
  end
end
