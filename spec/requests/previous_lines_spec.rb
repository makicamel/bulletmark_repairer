# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PreviousLinesController do
  let(:original_src) do
    <<-SRC
  def index
    @plays = Play.joins(:actors)
    @plays.each do |play|
      play.actors.map(&:name)
    end
  end
    SRC
  end
  let(:patched_src) do
    <<-SRC
  def index
    @plays = Play.joins(:actors)
    @plays.includes([:actors]).each do |play|
      play.actors.map(&:name)
    end
  end
    SRC
  end

  before { create(:play, :blast) }

  subject { get previous_lines_path }

  it_behaves_like 'correctly patched'
end
