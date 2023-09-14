# frozen_string_literal: true

class PreviousLinesController < ActionController::Base
  def index
    @plays = Play.joins(:actors)
    @plays.each do |play|
      play.actors.map(&:name)
    end
  end
end
