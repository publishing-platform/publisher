class PreviewDraftEditionService
  include Callable

  def initialize(edition, republish: false)
    @edition = edition
    @republish = republish
  end

  def call
    put_draft_content
    # TODO: - is there any point in attemting update of edition_synced in rescue? - all db changes will be rolled back as they are in a transaction in the interactor
    # rescue PublishingPlatformApi::BaseError
    #   edition.update!(edition_synced: false)
    #   raise
  end

private

  attr_reader :edition, :republish

  def put_draft_content
    payload = PublishingApiPayload.new(edition, republish:).payload
    PublishingPlatformApi.publishing_api.put_content(edition.content_id, payload)
    edition.update!(edition_synced: true)
  end
end
