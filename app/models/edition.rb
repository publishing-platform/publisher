# Respresents the current state of a piece of content that was once or is
# expected to be published on the publishing platform.
class Edition < ApplicationRecord
  attr_readonly :state

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
                withdrawn: "withdrawn",
                removed: "removed",
                discarded: "discarded",
                superseded: "superseded",
                failed_to_publish: "failed_to_publish" }

  def title_or_fallback
    title.presence || I18n.t!("documents.untitled_document")
  end

  def document_type
    DocumentType.find(document_type_id)
  end
end
