# Represents all versions of a piece of content.
class Document < ApplicationRecord
  attr_readonly :content_id

  belongs_to :created_by, class_name: "User"

  has_many :editions

  has_one :current_edition,
          -> { where(current: true) },
          class_name: "Edition",
          inverse_of: :document

  has_one :live_edition,
          -> { where(live: true) },
          class_name: "Edition",
          inverse_of: :document

  scope :with_current_edition, lambda {
    joins(:current_edition).includes(:current_edition)
  }

  def next_edition_number
    (editions.maximum(:number) || 0) + 1
  end  
end
