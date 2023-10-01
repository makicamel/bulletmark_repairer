# frozen_string_literal: true

require 'parser/current'

module BulletmarkRepairer
  module ActiveRecord
    module Core
      def const_added(const_name)
        if const_name == :GeneratedAssociationMethods
          mod = "#{self}::#{const_name}".constantize
          mod.singleton_class.prepend(
            Module.new do
              def class_eval(expr, fname, lineno)
                code = expr
                if expr =~ /^\s+association\(:\w+\)\.reader(\(\w+\))?\n/
                  buffer = Parser::Source::Buffer.new('(rewriter)').tap { |buf| buf.source = expr }
                  code = BulletmarkRepairer::AssociationPathcer.new.rewrite(buffer, Parser::CurrentRuby.parse(expr))
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

  class AssociationPathcer < Parser::TreeRewriter
    def on_def(node)
      insert_after node.location.name,
                   <<-SRC
          \n
          filename_index = caller.grep(%r{#{Rails.root}}).first.scan(%r{\\A([./\\w]+:\\d+):in `[\\w\\s]+'\\z}).flatten.first
          BulletmarkRepairer.tracers[filename_index] |= [__method__]
                   SRC
    end
  end
end
