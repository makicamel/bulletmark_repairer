# frozen_string_literal: true

FactoryBot.define do
  factory :actor do
    trait :yamato do
      name { 'yamato' }
      company { Company.find_by(name: 'takanashi') || create(:company, :takanashi) }
    end

    trait :ten do
      name { 'ten' }
      company { Company.find_by(name: 'yaotome') || create(:company, :yaotome) }
    end

    trait :gaku do
      name { 'gaku' }
      company { Company.find_by(name: 'yaotome') || create(:company, :yaotome) }
    end

    trait :ryunosuke do
      name { 'ryunosuke' }
      company { Company.find_by(name: 'yaotome') || create(:company, :yaotome) }
    end

    trait :yuki do
      name { 'yuki' }
      company { Company.find_by(name: 'okazaki') || create(:company, :okazaki) }
    end

    trait :haruka do
      name { 'haruka' }
      company { Company.find_by(name: 'tsukumo') || create(:company, :tsukumo) }
    end

    trait :toma do
      name { 'toma' }
      company { Company.find_by(name: 'tsukumo') || create(:company, :tsukumo) }
    end

    trait :minami do
      name { 'minami' }
      company { Company.find_by(name: 'tsukumo') || create(:company, :tsukumo) }
    end

    trait :torao do
      name { 'torao' }
      company { Company.find_by(name: 'tsukumo') || create(:company, :tsukumo) }
    end
  end
end
