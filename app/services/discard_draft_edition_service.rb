class DiscardDraftEditionService
  include Callable

  def initialize(edition, user, **)
    @edition = edition
    @user = user
  end

  def call
    raise "Only current editions can be deleted" unless edition.current?
    raise "Trying to delete a live edition" if edition.live?

    discard_draft(edition)
    reset_live_edition if document.live_edition
    # DiscardPathReservationsService.call(edition) if edition.first? # TODO?? - might need this for path reservations - don't think this is needed nh 21/06/2024
    document.reload_current_edition
  end

private

  attr_reader :edition, :user

  delegate :document, to: :edition

  def reset_live_edition
    document.live_edition.update!(current: true)
    document.reload_live_edition
  end

  def discard_draft(edition)
    # TODO: nh
    # begin
    #   GdsApi.publishing_api.discard_draft(edition.content_id)
    # rescue GdsApi::HTTPNotFound
    #   Rails.logger.warn("No draft to discard for content id #{edition.content_id}")
    # rescue GdsApi::HTTPUnprocessableEntity => e
    #   no_draft_message = "There is not a draft edition of this document to discard"

    #   if e.error_details.respond_to?(:dig) && e.error_details.dig("error", "message") == no_draft_message
    #     Rails.logger.warn("No draft to discard for content id #{edition.content_id}")
    #   else
    #     raise
    #   end
    # end

    edition.update!(last_edited_by: user, state: :discarded, current: false)
  end
end
