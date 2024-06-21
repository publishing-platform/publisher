class PreviewController < ApplicationController
  def create
    result = Preview::CreateInteractor.call(params:, user: current_user)
    @edition, issues, preview_failed = result.to_h.values_at(:edition, :issues, :preview_failed)

    if issues
      flash["requirements"] = {
        "title" => t("documents.show.flashes.pre_preview_issues.error"),
        "items" => issues.items(style: "summary", link_options: issues_link_options(@edition)),
      }
      redirect_to document_path(@edition.document)
    elsif preview_failed
      redirect_to document_path(params[:document_id]),
                  alert: t("documents.show.flashes.preview_error")
    else
      redirect_to preview_document_path(params[:document_id])
    end  
  end

  def show
    @edition = Edition.find_current(params[:document_id])
    assert_edition_state(@edition, assertion: "not live") { !@edition.live? }
  end

private

  def issues_link_options(edition)
    format_specific_options = edition.document_type.contents.each_with_object({}) do |field, memo|
      memo[field.id.to_sym] = { href: edition_path(edition.document, anchor: "#{field.id}-field") }
    end
    {
      title: { href: edition_path(edition.document, anchor: "title-field") },
    }.merge(Hash[format_specific_options])
  end  
end
