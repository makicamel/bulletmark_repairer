# frozen_string_literal: true

class NestedIncludesController < ActionController::Base
  def index
    @plays = Play.all
  end
end
