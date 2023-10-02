# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NestedIncludesController do
  let(:original_src) do
    <<-SRC
  def index
    @plays = Play.all
    @plays.each do |play|
      play.actors.each do |actor|
        actor.company.name
      end
    end
  end
    SRC
  end
  let(:patched_src) do
    <<-SRC
  def index
    @plays = Play.all
    @plays.includes([{:actors=>[:company]}]).each do |play|
      play.actors.each do |actor|
        actor.company.name
      end
    end
  end
    SRC
  end

  before do
    create(:play, :blast)
    create(:play, :crescent_wolf)
  end

  subject { get nested_includes_path }

  it_behaves_like 'correctly patched'
end
