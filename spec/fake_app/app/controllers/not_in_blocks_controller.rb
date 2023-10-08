# frozen_string_literal: true

class NotInBlocksController < ActionController::Base
  def index
    Play.all_actors_name
  end

  def show
    @plays = Play.all.as_json
  end

  def new
    plays = Play.all.as_json
    @play = plays.last
  end
end
