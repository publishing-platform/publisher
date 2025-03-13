FactoryBot.define do
  factory :edition do
    current { true }
    live { false }
    state { "draft" }
    update_type { "major" }
    title { SecureRandom.alphanumeric(10) }
    base_path { title ? "/#{title.parameterize}" : nil }
    association :created_by, factory: :user
    association :last_edited_by, factory: :user

    transient do
      content_id { SecureRandom.uuid }
      first_published_at { nil }
      document_type { build(:document_type) }
    end

    after(:build) do |edition, evaluator|
      unless edition.document
        args = [:document,
                evaluator.live ? :live : nil,
                { created_by: edition.created_by,
                  content_id: evaluator.content_id,
                  first_published_at: evaluator.first_published_at }]
        edition.document = evaluator.association(*args.compact)
      end

      edition.number = edition.document&.next_edition_number unless edition.number
      edition.document_type_id = evaluator.document_type_id || evaluator.document_type.id
    end

    trait :publishable do
      summary { SecureRandom.alphanumeric(10) }
    end

    trait :not_publishable do
      summary { "" }
    end

    trait :published do
      summary { SecureRandom.alphanumeric(10) }
      live { true }
      state { "published" }
      first_published_at { Time.zone.now }
      published_at { Time.zone.now }
    end
  end
end
