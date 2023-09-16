# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MultipleLinesController do
  let(:filename) { 'spec/fake_app/app/controllers/multiple_lines_controller.rb' }
  let(:original_src) do
    <<-SRC
  def index
    @plays = Play.joins(:actors)
    @plays.tap(&:size)
          .each do |play|
      play
        .actors
        .map(&:name)
    end
  end
    SRC
  end
  let(:patched_src) do
    <<-SRC
  def index
    @plays = Play.joins(:actors)
    @plays.tap(&:size).includes([:actors])
          .each do |play|
      play
        .actors
        .map(&:name)
    end
  end
    SRC
  end

  before { create(:play, :blast) }

  subject { get multiple_lines_path }

  it_behaves_like 'correctly patched'
end
