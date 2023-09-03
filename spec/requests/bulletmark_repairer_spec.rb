# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlaysController do
  it do
    get plays_path
    expect(response).to have_http_status 200
  end
end
