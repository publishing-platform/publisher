require "rails_helper"

RSpec.describe "Create a document", type: :system do
  scenario do
    create(:user)
    given_i_am_on_the_home_page
    when_i_click_to_create_a_document
    and_i_select_a_document_type
    and_i_fill_in_the_contents
    then_i_see_the_document_summary
  end

  def given_i_am_on_the_home_page
    visit root_path
  end

  def when_i_click_to_create_a_document
    click_on "Create new document"
  end

  def and_i_select_a_document_type
    choose "Answer"
    click_on "Continue"
  end

  def and_i_fill_in_the_contents
    fill_in "title", with: "A title"
    fill_in "summary", with: "A summary"
    click_on "Save"
  end

  def then_i_see_the_document_summary
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
    expect(page).to have_content("A summary")
  end
end
