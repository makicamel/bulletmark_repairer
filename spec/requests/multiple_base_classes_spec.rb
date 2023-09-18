# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MultipleBaseClassesController do
  let(:original_src) do
    <<-SRC
  def index
    @plays = Play.all
    @companies = Company.all
  end
    SRC
  end
  let(:patched_src) do
    <<-SRC
  def index
    @plays = Play.all.includes([:actors])
    @companies = Company.all.includes([:actors])
  end
    SRC
  end

  before do
    create(:play, :blast)
    create(:play, :crescent_wolf)
  end

  subject { get multiple_base_classes_path }

  it_behaves_like 'correctly patched'
end
