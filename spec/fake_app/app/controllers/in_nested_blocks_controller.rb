# frozen_string_literal: true

class InNestedBlocksController < ActionController::Base
  def index
    @plays = Play.all
    respond_to do |format|
      format.html do
        @plays.each do |play|
          play.actors.map(&:name)
        end
      end
    end
  end
end
