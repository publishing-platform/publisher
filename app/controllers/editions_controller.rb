class EditionsController < ApplicationController
  def edit
    @edition = Edition.find_current(params[:document_id])
    Rails.logger.debug issues_link_options(@edition)
    assert_edition_state(@edition, &:editable?)
  end

  def update
    result = Editions::UpdateInteractor.call(params:, user: current_user)
    edition, issues, = result.to_h.values_at(:edition, :issues)

    if issues
      flash.now["requirements"] = {
        "items" => issues.items(link_options: issues_link_options(edition)),
      }

      render :edit,
             assigns: { edition:, issues: },
             status: :unprocessable_entity
    else
      redirect_to edition.document
    end
  end

  def confirm_delete_draft
    @edition = Edition.find_current(params[:document_id])
    assert_edition_state(@edition, &:editable?)
  end  

  def destroy_draft
    result = Editions::DestroyInteractor.call(params:, user: current_user)

    if result.api_error
      redirect_to document_path(params[:document]),
                  alert: t("documents.show.flashes.delete_draft_error")
    else
      redirect_to documents_path
    end
  end  

private

  def issues_link_options(edition)
    format_specific_options = edition.document_type.contents.each_with_object({}) do |field, memo|
      memo[field.id.to_sym] = { href: "##{field.id}-field" }
    end
    {
      title: { href: "#title-field" },
    }.merge(Hash[format_specific_options])
  end
end
