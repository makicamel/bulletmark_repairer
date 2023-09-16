# frozen_string_literal: true

class SingleLinesController < ActionController::Base
  def show
    @plays = Play.joins(:actors)
    @plays.each { |play| play.actors.map { |actor| "name: #{actor.name}" } }
  end
end
