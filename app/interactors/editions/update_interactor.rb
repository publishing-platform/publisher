class Editions::UpdateInteractor < ApplicationInteractor
  delegate :params,
           :user,
           :edition,
           to: :context

  def call
    Edition.transaction do
      find_and_lock_edition
      check_for_issues

      update_edition
    end
  end

private

  def find_and_lock_edition
    context.edition = Edition.lock.find_current(params[:document_id])
    assert_edition_state(edition, &:editable?)
  end

  def check_for_issues
    issues = Requirements::Issues.new

    fields.each do |field|
      issues.push(*field.form_issues(edition, content_params))
    end

    context.fail!(issues:) if issues.any?
  end

  def update_edition
    # Rails.logger.debug content_params
    EditDraftEditionService.call(edition, user, content_params.merge(change_note_params))
    edition.save!
  end

  def change_note_params
    return {} if edition.first?

    { update_type: params[:update_type], change_note: params[:change_note] }
  end  

  def content_params
    @content_params ||= fields.reduce({}) do |hash, field|
      hash.merge!(field.updater_params(edition, params))
    end
  end

  def fields
    @fields ||= edition.document_type.contents
  end
end
