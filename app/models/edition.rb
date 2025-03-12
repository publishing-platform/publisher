# Respresents the current state of a piece of content that was once or is
# expected to be published on the publishing platform.
class Edition < ApplicationRecord
  belongs_to :created_by, class_name: "User"

  belongs_to :last_edited_by, class_name: "User"

  belongs_to :document

  scope :find_current, lambda { |document_id|
    where(current: true)
      .joins(:document)
      .includes(:document)
      .find_by!(document_id:)
  }

  enum state: { draft: "draft",
                submitted_for_review: "submitted_for_review",
                published: "published",
                published_but_needs_2i: "published_but_needs_2i",
                removed: "removed",
                discarded: "discarded",
                superseded: "superseded",
                failed_to_publish: "failed_to_publish" }

  enum update_type: { major: "major", minor: "minor" }

  attribute :auth_bypass_id, default: -> { SecureRandom.uuid }

  delegate :content_id, to: :document

  def title_or_fallback
    title.presence || I18n.t!("documents.untitled_document")
  end

  def document_type
    DocumentType.find(document_type_id)
  end

  def editable?
    !live?
  end

  def first?
    number == 1
  end

  def auth_bypass_token
    JWT.encode(
      {
        "sub" => auth_bypass_id,
        "content_id" => content_id,
        "iat" => Time.zone.now.to_i,
        "exp" => 1.month.from_now.to_i,
      },
      Rails.application.credentials.jwt_auth_secret,
      "HS256",
    )
  end
end
