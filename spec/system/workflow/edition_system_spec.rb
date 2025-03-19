require "rails_helper"

RSpec.describe "Editions", type: :system do
  before do
    given_there_is_a_published_edition
  end

  scenario "first edition" do
    when_i_visit_the_summary_page
    then_i_see_it_is_the_first_edition
  end

  scenario "major change" do
    when_i_visit_the_summary_page
    and_i_click_to_create_a_new_edition
    and_i_make_a_major_change
    then_i_see_there_is_a_new_major_edition
  end

  scenario "minor change" do
    when_i_visit_the_summary_page
    and_i_click_to_create_a_new_edition
    and_i_make_a_minor_change
    then_i_see_there_is_a_new_minor_edition
  end

  def given_there_is_a_published_edition
    @published_edition = create(:edition,
                                :published,
                                update_type: "major",
                                change_note: "First edition.")
  end

  def when_i_visit_the_summary_page
    visit document_path(@published_edition.document)
  end

  def then_i_see_it_is_the_first_edition
    expect(page).not_to have_content(I18n.t!("documents.show.contents.items.update_type"))
    expect(page).not_to have_content(I18n.t!("documents.show.contents.items.change_note"))
    expect(page).not_to have_link "Edit"
  end

  def and_i_click_to_create_a_new_edition
    click_on "Create new edition"
  end

  def and_i_make_a_minor_change
    choose I18n.t!("editions.edit.update_type.minor_name")
    click_on "Save"
  end

  def and_i_make_a_major_change
    fill_in "change_note", with: "I made a change"
    click_on "Save"
  end

  def then_i_see_there_is_a_new_minor_edition
    expect(page).to have_content(I18n.t!("documents.show.contents.update_type.minor"))
    expect(page).not_to have_content(I18n.t!("documents.show.contents.items.change_note"))
  end

  def then_i_see_there_is_a_new_major_edition
    expect(page).to have_content(I18n.t!("documents.show.contents.update_type.major"))
    expect(page).to have_content("I made a change")
    expect(page).to have_link("Edit")
  end
end
