require "rails_helper"

RSpec.describe "Edit an edition", type: :system do
  let(:contents) { { body: "Existing body" } }
  let(:document_type) { build(:document_type, :with_body) }
  let(:edition) { create(:edition, document_type:, contents:) }

  scenario do
    when_i_go_to_edit_the_edition
    and_i_fill_in_the_content_fields
    then_i_see_the_edition_is_saved
  end

  def when_i_go_to_edit_the_edition
    visit document_path(edition.document)
    expect(page).to have_content("Existing body")
    click_on "Edit"
  end

  def and_i_fill_in_the_content_fields
    fill_in "body", with: "Edited body."
    stub_request(:put, %r{.*publishing-api.*/content/#{edition.content_id}})
    click_on "Save"
  end

  def then_i_see_the_edition_is_saved
    expect(page).to have_content("Edited body.")
  end
end
