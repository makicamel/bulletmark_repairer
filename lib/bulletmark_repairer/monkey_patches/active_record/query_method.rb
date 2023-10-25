# frozen_string_literal: true

module BulletmarkRepairer
  module ActiveRecord
    module QueryMethod
      def includes(*args)
        Thread.current[:bulletmark_repaier_loaded_associations][model.name][:includes].add(args)
        super(args)
      end

      def eager_load(*args)
        Thread.current[:bulletmark_repaier_loaded_associations][model.name][:eager_load].add(args)
        super(args)
      end

      def preload(*args)
        Thread.current[:bulletmark_repaier_loaded_associations][model.name][:preload].add(args)
        super(args)
      end
    end
  end
end
