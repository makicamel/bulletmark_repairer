# frozen_string_literal: true

class NPlusOneInViewsController < ActionController::Base
  def show
    @plays = Play.joins(:actors)
  end

  def index
    @plays = Play.all
    @plays = @plays.joins(:actors)
  end
end
