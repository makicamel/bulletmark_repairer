# frozen_string_literal: true

class NestedThoughOnlyGrandChildIsRequiredIncludesController < ActionController::Base
  def index
    @plays = Play.includes(:actors)
  end
end
