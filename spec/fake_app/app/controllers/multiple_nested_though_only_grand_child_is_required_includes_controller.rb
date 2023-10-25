# frozen_string_literal: true

class MultipleNestedThoughOnlyGrandChildIsRequiredIncludesController < ActionController::Base
  def index
    @plays = Play.includes(:actors)
  end
end
