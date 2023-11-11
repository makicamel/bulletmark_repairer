# frozen_string_literal: true

module BulletmarkRepairer
  module ActiveRecord
    module QueryMethod
      def includes(*args)
        BulletmarkRepairer::Thread.memorize_associations(name: model.name, method_type: :includes, args: args)
        super(args)
      end

      def eager_load(*args)
        BulletmarkRepairer::Thread.memorize_associations(name: model.name, method_type: :eager_load, args: args)
        super(args)
      end

      def preload(*args)
        BulletmarkRepairer::Thread.memorize_associations(name: model.name, method_type: :preload, args: args)
        super(args)
      end
    end
  end
end
