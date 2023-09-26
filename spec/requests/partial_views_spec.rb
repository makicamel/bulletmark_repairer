# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PartialViewsController do
  let(:original_src) do
    <<-SRC
  def index
    @plays = Play.joins(:actors)
  end
    SRC
  end
  let(:patched_src) do
    <<-SRC
  def index
    @plays = Play.joins(:actors).includes([:actors])
  end
    SRC
  end

  before { create(:play, :blast) }

  subject { get partial_views_path }

  it_behaves_like 'correctly patched'
end
