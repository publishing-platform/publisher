module ActionsHelper
  def publish_link(edition)
    link_to "Publish",
            publish_confirmation_path(edition.document)
  end
end