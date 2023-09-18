# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AvoidIncludesController do
  let(:src) do
    <<-SRC
  def index
    @plays = Play.all.includes(:actors)
    @plays.each { |play| play.name }
  end
    SRC
  end

  before { create(:play, :blast) }

  subject { get avoid_includes_path }

  it_behaves_like 'not patched'

  it do
    subject
    expect(BulletmarkRepairer.markers.instance_variable_get(:@markers)).to eq({})
  end
end
