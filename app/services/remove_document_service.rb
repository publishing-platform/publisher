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
      unpublish_with_redirect(edition, redirect_url)
    else
      unpublish_without_redirect(edition)
    end

    edition.update!(last_edited_by: user, state: :removed)
  end

  def check_removable
    document = edition.document

    if edition != document.live_edition
      raise "attempted to remove an edition other than the live edition"
    end
  end

  def unpublish_with_redirect(edition, redirect_url)
    PublishingPlatformApi.publishing_api.unpublish(
      edition.content_id,
      type: "redirect",
      alternative_path: redirect_url,
      discard_drafts: true,
    )
  end

  def unpublish_without_redirect(edition)
    PublishingPlatformApi.publishing_api.unpublish(
      edition.content_id,
      type: "gone",
      discard_drafts: true,
    )
  end
end
