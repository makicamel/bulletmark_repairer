# frozen_string_literal: true

class Play < ActiveRecord::Base
  has_many :play_actors
  has_many :actors, through: :play_actors
  has_many :main_actors, through: :play_actors, source: :actor

  scope :all_actors_name, -> { all.map { |play| play.actors.map(&:name) } }

  def as_json
    { actors: actors.map(&:name) }
  end
end
