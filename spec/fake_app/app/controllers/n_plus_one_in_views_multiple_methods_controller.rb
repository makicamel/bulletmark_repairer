# frozen_string_literal: true

class NPlusOneInViewsMultipleMethodsController < ActionController::Base
  def index
    assign_plays
  end

  private

  def not_called1
    @plays = Play.joins(:actors)
  end

  def assign_plays
    @plays = Play.joins(:actors)
  end

  def not_called2
    @plays = Play.joins(:actors)
  end
end
