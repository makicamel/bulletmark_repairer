# frozen_string_literal: true

class NestedAndAnotherNameIncludesController < ActionController::Base
  def index
    @plays = Play.all
  end
end
