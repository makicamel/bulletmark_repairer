# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InstanceVariablesController do
  let(:original_src) do
    <<-SRC
  def index
    @favorite = true
    @plays = Play.all
  end
    SRC
  end
  let(:patched_src) do
    <<-SRC
  def index
    @favorite = true
    @plays = Play.all.includes([:actors])
  end
    SRC
  end

  before do
    create(:play, :blast)
    create(:play, :crescent_wolf)
  end

  subject { get instance_variables_path }

  it_behaves_like 'correctly patched'
end
