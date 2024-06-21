class PublishController < ApplicationController
  def confirmation
    result = Publish::ConfirmationInteractor.call(params:, user: current_user)
    @edition, issues = result.to_h.values_at(:edition,
                                             :issues)

    if issues
      flash["requirements"] = {
        "title" => t("documents.show.flashes.pre_publish_issues.error"),
        "items" => issues.items(style: "summary", link_options: issues_link_options(@edition)),
      }
      redirect_to document_path(@edition.document)
    end
  end

  def publish
    result = Publish::PublishInteractor.call(params:, user: current_user)

    edition, issues, publish_failed = result.to_h.values_at(:edition,
                                                            :issues,
                                                            :publish_failed)
    if issues
      flash.now["requirements"] = { "items" => issues.items }

      render :confirmation,
             assigns: { issues:, edition: },
             status: :unprocessable_entity
    elsif publish_failed
      redirect_to document_path(edition.document),
                  alert: t("documents.show.flashes.publish_error")
    else
      redirect_to published_path(edition.document)
    end
  end

  def published
    @edition = Edition.find_current(params[:document_id])
    assert_edition_state(@edition, assertion: "is published") do
      @edition.published? || @edition.published_but_needs_2i?
    end
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
