# frozen_string_literal: true

class NotInBlocksController < ActionController::Base
  def index
    Play.all_actors_name
  end
end
