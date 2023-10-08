# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MultipleLinesController do
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
    @plays = Play.joins(:actors).includes([:actors])
    @plays.tap(&:size)
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
