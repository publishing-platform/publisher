class Withdraw::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :issues,
           :api_error,
           :already_removed,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
      remove_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(params[:document_id])

    assert_edition_state(edition, assertion: "is published") do
      edition.published? || edition.published_but_needs_2i?
    end
  end

  def check_for_issues
    issues = Requirements::Form::RemovalChecker.call(edition, params[:public_explanation])
    context.fail!(issues:) if issues.any?    
  end

  def remove_edition
    RemoveDocumentService.call(edition,
                                 user,
                                 redirect_url: make_url_relative(params[:redirect_url]))
  # TODO
  # rescue GdsApi::BaseError => e
  #   GovukError.notify(e)
  #   context.fail!(api_error: true)
  end

  def make_url_relative(url = "")
    url.sub(%r{^(https?://)?(www\.)?gov\.uk/}, "/")
  end

end