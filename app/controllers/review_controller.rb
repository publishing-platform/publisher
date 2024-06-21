class ReviewController < ApplicationController
  def submit_for_2i
    result = Review::SubmitFor2iInteractor.call(params:, user: current_user)
    issues, edition = result.to_h.values_at(:issues, :edition)

    if issues
      flash["requirements"] = {
        "items" => issues.items(style: "summary", link_options: issues_link_options(edition)),
      }
    end

    redirect_to document_path(params[:document_id])
  end

  def approve
    Review::ApproveInteractor.call(params:, user: current_user)

    redirect_to document_path(params[:document_id]),
                notice: t("documents.show.flashes.approved")
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
