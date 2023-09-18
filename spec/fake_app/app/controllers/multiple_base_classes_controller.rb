# frozen_string_literal: true

class MultipleBaseClassesController < ActionController::Base
  def index
    @plays = Play.all
    @companies = Company.all
  end
end
