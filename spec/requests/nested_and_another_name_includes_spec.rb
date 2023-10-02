# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NestedAndAnotherNameIncludesController do
  let(:original_src) do
    <<-SRC
  def index
    @plays = Play.all
  end
    SRC
  end
  let(:patched_src) do
    <<-SRC
  def index
    @plays = Play.all.includes([{:main_actors=>[:company]}])
  end
    SRC
  end

  before do
    create(:play, :blast)
    create(:play, :crescent_wolf)
  end

  subject { get nested_and_another_name_includes_path }

  it_behaves_like 'correctly patched'
end
