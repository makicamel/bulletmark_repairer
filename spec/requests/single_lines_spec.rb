# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SingleLinesController do
  let(:original_src) do
    <<-SRC
  def show
    @plays = Play.joins(:actors)
    @plays.each { |play| play.actors.map { |actor| "name: \#{actor.name}" } }
  end
    SRC
  end
  let(:patched_src) do
    <<-SRC
  def show
    @plays = Play.joins(:actors)
    @plays.includes([:actors]).each { |play| play.actors.map { |actor| "name: \#{actor.name}" } }
  end
    SRC
  end

  before { create(:play, :blast) }

  subject { get single_line_path }

  it_behaves_like 'correctly patched'
end
