# frozen_string_literal: true

# rubocop:disable Layout/IndentationWidth
class MultipleLinesController < ActionController::Base
  def index
    @plays = Play.joins(:actors)
    @plays.tap(&:size)
          .each do |play|
      play
        .actors
        .map(&:name)
    end
  end
end
# rubocop:enable Layout/IndentationWidth
