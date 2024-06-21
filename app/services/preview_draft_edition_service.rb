class PreviewDraftEditionService
  include Callable

  def initialize(edition, republish: false)
    @edition = edition
    @republish = republish
  end

  def call
    put_draft_content
  # TODO
  # rescue GdsApi::BaseError
  #   edition.update!(revision_synced: false)
  #   raise
  end

private

  attr_reader :edition, :republish

  def put_draft_content
    # TODO
    # payload = PublishingApiPayload.new(edition, republish:).payload
    # GdsApi.publishing_api.put_content(edition.content_id, payload)
    edition.update!(revision_synced: true)
  end
end