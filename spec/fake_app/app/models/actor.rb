# frozen_string_literal: true

class Actor < ActiveRecord::Base
  belongs_to :company
  has_many :play_actors
  has_many :plays, through: :play_actors
end
