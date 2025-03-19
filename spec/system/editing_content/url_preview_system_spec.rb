require "rails_helper"

RSpec.describe "Shows a preview of the URL", type: :system do
  let(:document_type) { build(:document_type, contents: [DocumentType::TitleAndBasePathField.new]) }
  let(:edition) { create(:edition, document_type:) }

  scenario do
    when_i_go_to_edit_the_edition
    and_i_delete_the_title
    then_i_see_a_prompt_to_enter_a_title
    and_i_fill_in_the_title
    then_i_see_a_preview_of_the_url_on_publishing_platform
  end

  def when_i_go_to_edit_the_edition
    visit document_path(edition.document)
    click_on "Edit"
  end

  def and_i_delete_the_title
    fill_in("title", with: "")
    page.find("body").click
  end

  def then_i_see_a_prompt_to_enter_a_title
    expect(page).to have_content(I18n.t!("editions.edit.url_preview.no_title"))
  end

  def and_i_fill_in_the_title
    fill_in("title", with: "A great title")
    page.find("body").native.send_keys :tab
  end

  def then_i_see_a_preview_of_the_url_on_publishing_platform
    expect(page).to have_content("www.test.publishing-platform.co.uk/a-great-title")
  end
end
