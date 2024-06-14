module EditionUrlHelper
  def edition_public_url(edition)
    return unless edition.base_path

    PublishingPlatformLocation.website_root + edition.base_path
  end
end
