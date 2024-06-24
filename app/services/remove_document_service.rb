class RemoveDocumentService
  include Callable

  def initialize(edition, user, redirect_url:)
    @edition = edition
    @redirect_url = redirect_url
    @user = user
  end

  def call
    edition.document.lock!
    check_removable
    unpublish_edition
  end

private

  attr_reader :edition, :redirect_url, :user

  def unpublish_edition
    if redirect_url.present?
    else
    end
    GdsApi.publishing_api.unpublish(
      edition.content_id,
      type: "withdrawal",
      explanation: format_govspeak(public_explanation, edition),
      locale: edition.locale,
      unpublished_at: edition.status.details.withdrawn_at,
    )

    edition.update!(last_edited_by: user, state: :removed)    
  end

  def update_edition(withdrawal)
    AssignEditionStatusService.call(edition,
                                    user:,
                                    state: :withdrawn,
                                    status_details: withdrawal)
    edition.save!
  end

  def check_removable
    document = edition.document

    if edition != document.live_edition
      raise "attempted to remove an edition other than the live edition"
    end

    if document.current_edition != document.live_edition
      raise "Publishing API does not support unpublishing while there is a draft"
    end
  end
end