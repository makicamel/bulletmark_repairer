# frozen_string_literal: true

class NestedIncludesInViewsController < ActionController::Base
  def index
    @plays = Play.all
  end
end
