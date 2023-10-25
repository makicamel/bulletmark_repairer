# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NestedThoughOnlyGrandChildIsRequiredIncludesController do
  let(:original_src) do
    <<-SRC
  def index
    @plays = Play.includes(:actors)
  end
    SRC
  end
  let(:patched_src) do
    <<-SRC
  def index
    @plays = Play.includes(:actors).includes({:actors=>[:company]})
  end
    SRC
  end

  before do
    create(:play, :blast)
    create(:play, :crescent_wolf)
  end

  subject { get nested_though_only_grand_child_is_required_includes_path }

  it_behaves_like 'correctly patched'
end
