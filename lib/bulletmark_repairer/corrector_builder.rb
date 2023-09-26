# frozen_string_literal: true

module BulletmarkRepairer
  class CorrectorBuilder
    def initialize(dir:, marker:)
      @dir = dir
      @marker = marker
    end

    def execute
      corrector_name = @marker.n_plus_one_in_view? ? '/controller_corrector.rb' : '/corrector.rb'
      File.open("#{@dir}#{corrector_name}", 'w') do |f|
        corrector = Pathname.new(__FILE__).sub('/corrector_builder.rb', corrector_name)
        f.puts File.read(corrector)
        f
      end.path
    end
  end
end
