# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotInBlocksController do
  describe '#index' do
    let(:original_src) do
      <<-SRC
  def index
    Play.all_actors_name
  end
      SRC
    end

    let(:patched_src) do
      <<-SRC
  def index
    Play.all_actors_name.includes([:actors])
  end
      SRC
    end

    before do
      create(:play, :blast)
      create(:play, :crescent_wolf)
    end

    subject { get not_in_blocks_path }

    it_behaves_like 'correctly patched'
  end

  describe '#show' do
    let(:original_src) do
      <<-SRC
  def show
    @plays = Play.all.as_json
  end
      SRC
    end

    let(:patched_src) do
      <<-SRC
  def show
    @plays = Play.all.as_json.includes([:actors])
  end
      SRC
    end

    before do
      create(:play, :blast)
      create(:play, :crescent_wolf)
    end

    subject { get not_in_block_path(Play.last) }

    it_behaves_like 'correctly patched'
  end

  describe '#new' do
    let(:original_src) do
      <<-SRC
  def new
    plays = Play.all.as_json
    @play = plays.last
  end
      SRC
    end

    let(:patched_src) do
      <<-SRC
  def new
    plays = Play.all.as_json.includes([:actors])
    @play = plays.last
  end
      SRC
    end

    before do
      create(:play, :blast)
      create(:play, :crescent_wolf)
    end

    subject { get new_not_in_block_path }

    it_behaves_like 'correctly patched'
  end
end
