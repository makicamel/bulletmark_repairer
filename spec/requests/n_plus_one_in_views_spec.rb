# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NPlusOneInViewsController do
  let(:original_src) do
    <<-SRC
  def index
    @plays = Play.all
    @plays = @plays.joins(:actors)
  end
    SRC
  end
  let(:patched_src) do
    <<-SRC
  def index
    @plays = Play.all
    @plays = @plays.joins(:actors).includes([:actors])
  end
    SRC
  end

  before { create(:play, :blast) }

  subject { get n_plus_one_in_views_path }

  it_behaves_like 'correctly patched'
end
