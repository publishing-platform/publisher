class PublishController < ApplicationController
  def confirmation
    result = Publish::ConfirmationInteractor.call(params:, user: current_user)
    @edition = result.edition
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
    @edition = Edition.find_current(document: params[:document])
    assert_edition_state(@edition, assertion: "is published") do
      @edition.published? || @edition.published_but_needs_2i?
    end
  end
end
