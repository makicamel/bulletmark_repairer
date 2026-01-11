# frozen_string_literal: true

module BulletmarkRepairer
  module ActionView
    module Base
      def initialize(*args)
        super
        @_assigns.each do |ivname, value|
          BulletmarkRepairer::Thread.memorize_instance_variable_name(name: ivname, value: value)
        end
      end
    end
  end
end
