class EditDraftEditionService
  include Callable

  def initialize(edition, user, attributes)
    @edition = edition
    @user = user
    @attributes = attributes
  end

  def call
    raise "cannot edit a live edition" if edition.live?

    edition.assign_attributes(extended_attributes)
  end

private

  attr_reader :edition, :user, :attributes

  def extended_attributes
    attributes.merge(last_edited_by: user)
  end
end