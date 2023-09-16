# frozen_string_literal: true

class MultipleActionsController < ActionController::Base
  before_action :set_plays

  def index
    @plays.each { |play| play.actors.map { |actor| "index name: #{actor.name}" } }
  end

  def show
    @plays.each { |play| play.actors.map { |actor| "show name: #{actor.name}" } }
  end

  private

  def set_plays
    @plays = Play.all
  end
end
