FactoryBot.define do
  factory :document do
    content_id { SecureRandom.uuid }
    association :created_by, factory: :user

    trait :live do
      first_published_at { Time.zone.now }
    end
  end
end
