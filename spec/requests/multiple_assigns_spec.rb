# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MultipleAssignsController do
  let(:original_src) do
    <<-SRC
  def index
    @plays = Play.all
    @plays = @plays.where('name LIKE ?', 'mission%')
  end
    SRC
  end
  let(:patched_src) do
    <<-SRC
  def index
    @plays = Play.all.includes([:actors])
    @plays = @plays.where('name LIKE ?', 'mission%')
  end
    SRC
  end

  before do
    create(:play, :mission)
    create(:play, name: 'mission2', actors: [Actor.find_by(name: 'yuki'), Actor.find_by(name: 'yamato'), Actor.find_by(name: 'minami')])
  end

  subject { get multiple_assigns_path }

  it_behaves_like 'correctly patched'
end
