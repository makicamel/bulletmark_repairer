# frozen_string_literal: true

FactoryBot.define do
  factory :play do
    trait :mission do
      name { 'mission' }
      before(:create) do |play|
        play.actors = [
          Actor.find_by(name: 'yuki') || create(:actor, :yuki),
          Actor.find_by(name: 'yamato') || create(:actor, :yamato),
          Actor.find_by(name: 'minami') || create(:actor, :minami)
        ]
      end
    end

    trait :blast do
      name { 'blast' }
      before(:create) do |play|
        play.actors = [
          Actor.find_by(name: 'haruka') || create(:actor, :haruka),
          Actor.find_by(name: 'toma') || create(:actor, :toma),
          Actor.find_by(name: 'minami') || create(:actor, :minami),
          Actor.find_by(name: 'torao') || create(:actor, :torao)
        ]
      end
    end

    trait :crescent_wolf do
      name { 'crescent_wolf' }
      before(:create) do |play|
        play.actors = [
          Actor.find_by(name: 'ten') || create(:actor, :ten),
          Actor.find_by(name: 'gaku') || create(:actor, :gaku),
          Actor.find_by(name: 'ryunosuke') || create(:actor, :ryunosuke)
        ]
      end
    end
  end
end
