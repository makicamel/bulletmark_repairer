# frozen_string_literal: true

class NestedIncludesController < ActionController::Base
  def index
    @plays = Play.all
    @plays.each do |play|
      play.actors.each do |actor|
        actor.company.name
      end
    end
  end
end
