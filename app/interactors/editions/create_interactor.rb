class Editions::CreateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           :next_edition,
           :discarded_edition,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      create_next_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(params[:document_id])
    context.discarded_edition = Edition.find_by(document: edition.document,
                                                number: edition.number + 1)
    assert_edition_state(edition, assertion: "can create new edition") { edition.live }
  end

  def create_next_edition
    context.next_edition = CreateNextEditionService.call(current_edition: edition,
                                                         user:,
                                                         discarded_edition:)
  end
end