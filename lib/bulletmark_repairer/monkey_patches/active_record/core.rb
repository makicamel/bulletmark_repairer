# frozen_string_literal: true

require 'parser/current'

module BulletmarkRepairer
  module ActiveRecord
    module Core
      # TODO: compatible under Ruby 3.2
      def const_added(const_name)
        if const_name == :GeneratedAssociationMethods && try(:name)
          mod = "#{self}::#{const_name}".constantize
          mod.singleton_class.prepend(
            Module.new do
              def class_eval(expr, fname, lineno)
                code = expr
                if expr =~ /^\s+association\(:\w+\)\.reader(\(\w+\))?\n/
                  buffer = Parser::Source::Buffer.new('(rewriter)').tap { |buf| buf.source = expr }
                  code = BulletmarkRepairer::CallerCollector.new.rewrite(buffer, Parser::CurrentRuby.parse(expr))
                end
                super(code, fname, lineno)
              end
            end
          )
        end
        super
      end
    end
  end

  class CallerCollector < Parser::TreeRewriter
    def on_def(node)
      insert_after node.location.name,
                   <<-SRC
          \n
          # TODO: allowed directories list
          BulletmarkRepairer.add_caller(base_class: self.class.name, callers: caller.grep(%r{#{Rails.root}/app/(controllers|views)}))
                   SRC
    end
  end
end
