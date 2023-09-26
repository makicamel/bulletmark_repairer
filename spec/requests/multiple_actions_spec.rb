# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MultipleActionsController do
  describe 'GET #index' do
    let(:original_src) do
      <<-SRC
  def index
    @plays.each { |play| play.actors.map { |actor| "index name: \#{actor.name}" } }
  end
      SRC
    end
    let(:patched_src) do
      <<-SRC
  def index
    @plays.includes([:actors]).each { |play| play.actors.map { |actor| "index name: \#{actor.name}" } }
  end
      SRC
    end

    before do
      create(:play, :blast)
      create(:play, :crescent_wolf)
    end

    subject { get multiple_actions_path }

    it_behaves_like 'correctly patched'
  end

  describe 'GET #show' do
    let(:original_src) do
      <<-SRC
  def show
    @plays.each { |play| play.actors.map { |actor| "show name: \#{actor.name}" } }
  end
      SRC
    end
    let(:patched_src) do
      <<-SRC
  def show
    @plays.includes([:actors]).each { |play| play.actors.map { |actor| "show name: \#{actor.name}" } }
  end
      SRC
    end

    let(:play) { [create(:play, :blast), create(:play, :crescent_wolf)].sample }

    subject { get multiple_action_path(play) }

    # it_behaves_like 'correctly patched'
  end
end
