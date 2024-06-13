class Publish::ConfirmationInteractor < ApplicationInteractor
  delegate :user,
           :params,
           :edition,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.find_current(params[:document_id])
    assert_edition_state(edition, &:editable?)
  end

  def check_for_issues
  end  
end