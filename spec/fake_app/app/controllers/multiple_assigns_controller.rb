# frozen_string_literal: true

class MultipleAssignsController < ActionController::Base
  def index
    @plays = Play.all
    @plays = @plays.where('name LIKE ?', 'mission%')
  end
end
