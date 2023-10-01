# frozen_string_literal: true

class AnotherNameAssociationsController < ActionController::Base
  def index
    @plays = Play.all
  end
end
