class Publish::PublishInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :issues,
           :publish_failed,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues

      publish_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(params[:document_id])
    assert_edition_state(edition, &:editable?)

    assert_edition_state(edition, assertion: "has no requirements issues") do
      Requirements::Publish::EditionChecker.call(edition).none?
    end
  end

  def check_for_issues
    issues = Requirements::Issues.new
    issues.create(:review_status, :not_selected) if params[:review_status].blank?
    context.fail!(issues:) if issues.any?
  end

  def with_review?
    params[:review_status] == "reviewed"
  end

  def publish_edition
    PublishDraftEditionService.call(edition, user, with_review: with_review?)
    # TODO
    # rescue GdsApi::BaseError
    #   context.fail!(publish_failed: true)
  end
end
