# frozen_string_literal: true

module BulletmarkRepairer
  class CorrectorBuilder
    ASSOCIATIONS = '__EMBEDDED_ASSOCIATIONS__'
    LINE_NO = '__EMBEDDED_LINE_NO__'
    ACTION = '__EMBEDDED_ACTION__'
    INSTANCE_VARIABLE_NAME = '__EMBEDDED_INSTANCE_VARIABLE_NAME__'

    def initialize(dir:, marker:, associations:)
      @dir = dir
      @marker = marker
      @associations = associations
      @action = marker.action
      @instance_variable_name = marker.instance_variable_name
    end

    def execute
      if @marker.retry
        corrector_name = '/retry_corrector.rb'
        File.open("#{@dir}#{corrector_name}", 'w') do |f|
          corrector = Pathname.new(__FILE__).sub('/corrector_builder.rb', corrector_name)
          src = File.read(corrector)
          src
            .sub!(ASSOCIATIONS, to_hash_rocket_syntax(@associations[:base]))
            .sub!(LINE_NO, @marker.line_no)
          f.puts src
          f
        end.path
      else
        corrector_name = '/controller_corrector.rb'
        File.open("#{@dir}#{corrector_name}", 'w') do |f|
          corrector = Pathname.new(__FILE__).sub('/corrector_builder.rb', corrector_name)
          src = File.read(corrector)
          src
            .sub!(ASSOCIATIONS, to_hash_rocket_syntax(@associations[:base]))
            .sub!(ACTION, @action)
            .sub!(INSTANCE_VARIABLE_NAME, @instance_variable_name)
          f.puts src
          f
        end.path
      end
    end

    private

    def to_hash_rocket_syntax(obj)
      case obj
      when Hash
        pairs = obj.map { |k, v| "#{k.inspect}=>#{to_hash_rocket_syntax(v)}" }
        "{#{pairs.join(', ')}}"
      when Array
        "[#{obj.map { |v| to_hash_rocket_syntax(v) }.join(', ')}]"
      else
        obj.inspect
      end
    end
  end
end
