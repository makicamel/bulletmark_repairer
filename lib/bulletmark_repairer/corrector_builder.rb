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
      @line_no = marker.line_no
      @action = marker.instance_variable_get(:@action)
      @instance_variable_name = marker.instance_variable_name_in_view
    end

    def execute
      corrector_name = @marker.n_plus_one_in_view? ? '/controller_corrector.rb' : '/corrector.rb'
      File.open("#{@dir}#{corrector_name}", 'w') do |f|
        corrector = Pathname.new(__FILE__).sub('/corrector_builder.rb', corrector_name)
        src = File.read(corrector)
        if @marker.n_plus_one_in_view?
          src
            .sub!(ASSOCIATIONS, @associations.to_s)
            .sub!(ACTION, @action)
            .sub!(INSTANCE_VARIABLE_NAME, @instance_variable_name)
        else
          src
            .sub!(ASSOCIATIONS, @associations.to_s)
            .sub!(LINE_NO, @line_no.to_s)
        end
        f.puts src
        f
      end.path
    end
  end
end
