class GenerateBasePathService
  include Callable

  def initialize(edition, title:)
    @edition = edition
    @title = title.to_s
  end

  def call
    prefix = edition.document_type.path_prefix
    slug = title.parameterize
    create_path(prefix, slug)
  end

private

  attr_reader :edition, :title

  def create_path(prefix, slug)
    "#{prefix}/#{slug}"
  end
end
