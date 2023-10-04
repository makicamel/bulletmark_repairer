# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotInBlocksController do
  let(:src) do
    <<-SRC
  def index
    Play.all_actors_name
  end
    SRC
  end

  before do
    create(:play, :blast)
    create(:play, :crescent_wolf)
  end

  subject { get not_in_blocks_path }

  it_behaves_like 'not patched'
end
