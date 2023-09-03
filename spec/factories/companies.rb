# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    trait :takanashi do
      name { 'takanashi' }
    end

    trait :yaotome do
      name { 'yaotome' }
    end

    trait :okazaki do
      name { 'okazaki' }
    end

    trait :tsukumo do
      name { 'tsukumo' }
    end
  end
end
