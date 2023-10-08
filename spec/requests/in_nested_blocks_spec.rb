# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InNestedBlocksController do
  let(:original_src) do
    <<-SRC
  def index
    @plays = Play.all
    respond_to do |format|
      format.html do
        @plays.each do |play|
          play.actors.map(&:name)
        end
      end
    end
  end
    SRC
  end

  let(:patched_src) do
    <<-SRC
  def index
    @plays = Play.all.includes([:actors])
    respond_to do |format|
      format.html do
        @plays.each do |play|
          play.actors.map(&:name)
        end
      end
    end
  end
    SRC
  end

  before do
    create(:play, :blast)
    create(:play, :crescent_wolf)
  end

  subject { get in_nested_blocks_path }

  it_behaves_like 'correctly patched'
end
