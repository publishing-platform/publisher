require "rails_helper"

RSpec.describe "Index filtering", type: :system do
  scenario do
    given_there_are_some_editions
    when_i_visit_the_index_page
    then_i_see_all_editions

    when_i_clear_the_filters
    and_i_filter_by_title
    then_i_see_just_the_ones_that_match

    when_i_clear_the_filters
    then_i_see_all_editions

    when_i_filter_by_document_type
    then_i_see_just_the_ones_that_match

    when_i_clear_the_filters
    and_i_filter_by_state
    then_i_see_just_the_ones_that_match

    when_i_clear_the_filters
    and_i_filter_too_much
    then_i_see_there_are_no_results
  end

  def given_there_are_some_editions
    @relevant_edition = create(:edition, title: "Super relevant")
    @irrelevant_edition = create(:edition, :published, title: "Irrelevant")
  end

  def when_i_visit_the_index_page
    visit documents_path
  end

  def then_i_see_all_editions
    expect(page).to have_content("2 documents")
  end

  def and_i_filter_by_title
    fill_in "title_or_url", with: "super"
    click_on "Filter"
  end

  def when_i_clear_the_filters
    click_on "Clear all filters"
  end

  def then_i_see_just_the_ones_that_match
    expect(page).to have_content("1 document")
    expect(page).to have_content(@relevant_edition.title)
  end

  def when_i_filter_by_document_type
    select @relevant_edition.document_type.label, from: "document_type"
    click_on "Filter"
  end

  def and_i_filter_by_state
    select I18n.t!("user_facing_states.draft.name"), from: "state"
    click_on "Filter"
  end

  def and_i_filter_too_much
    fill_in "title_or_url", with: SecureRandom.uuid
    click_on "Filter"
  end

  def then_i_see_there_are_no_results
    expect(page).to have_content("0 documents")
  end
end
