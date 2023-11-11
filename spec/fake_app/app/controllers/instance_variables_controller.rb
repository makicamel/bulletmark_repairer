# frozen_string_literal: true

class InstanceVariablesController < ActionController::Base
  def index
    @favorite = true
    @plays = Play.all
  end
end
