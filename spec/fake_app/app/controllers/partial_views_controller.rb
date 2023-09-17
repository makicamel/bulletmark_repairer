# frozen_string_literal: true

class PartialViewsController < ActionController::Base
  def index
    @plays = Play.joins(:actors)
  end
end
