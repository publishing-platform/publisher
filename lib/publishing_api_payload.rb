class PublishingApiPayload
  PUBLISHING_APP = "publisher".freeze

  attr_reader :edition, :document_type, :publishing_metadata, :republish

  def initialize(edition, republish: false)
    @edition = edition
    @document_type = edition.document_type
    @publishing_metadata = document_type.publishing_metadata
    @republish = republish
  end

  def payload
    payload = {
      schema_name: publishing_metadata.schema_name,
      document_type: document_type.id,
      publishing_app: PUBLISHING_APP,
      rendering_app: publishing_metadata.rendering_app,
      update_type: edition.update_type,
      details:,
      auth_bypass_ids: [edition.auth_bypass_id],
      public_updated_at: history.public_updated_at,
    }
    payload[:first_published_at] = history.first_published_at if history.first_published_at.present?

    fields = document_type.contents
    fields.each { |f| payload.deep_merge!(f.payload(edition)) }

    if republish
      payload[:update_type] = "republish"
    end

    payload
  end

private

  def history
    @history ||= History.new(edition)
  end

  def details
    {
      change_history: history.change_history,
    }
  end
end