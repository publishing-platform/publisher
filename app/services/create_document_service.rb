class CreateDocumentService
  include Callable

  def initialize(document_type_id:,
                 content_id: SecureRandom.uuid,
                 user: nil)
    @content_id = content_id
    @document_type_id = document_type_id
    @user = user
  end

  def call
    Document.transaction do
      Document.create!(
        content_id:,
        created_by: user,
      ).tap { |d| create_edition(d) }
    end
  end

private

  attr_reader :content_id, :document_type_id, :user

  def create_edition(document)
    edition = Edition.new(
      document:,
      document_type_id:,
      state: :draft,
      created_by: user,
      current: true,
      last_edited_by: user,
      number: 1,
      update_type: "major",
    )

    edition.save!

    edition
  end
end
