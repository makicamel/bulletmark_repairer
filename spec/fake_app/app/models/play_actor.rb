# frozen_string_literal: true

class PlayActor < ActiveRecord::Base
  belongs_to :play
  belongs_to :actor
end
