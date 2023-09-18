# frozen_string_literal: true

class AvoidIncludesController < ActionController::Base
  def index
    @plays = Play.all.includes(:actors)
    @plays.each(&:name)
  end
end
