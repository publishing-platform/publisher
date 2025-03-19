require "rails_helper"

RSpec.describe "Delete draft", type: :system do
  scenario do
    given_there_is_an_edition
    when_i_visit_the_summary_page
    and_i_delete_the_draft
    then_i_see_the_edition_is_gone
    and_the_draft_is_discarded
  end

  def given_there_is_an_edition
    @user = create(:user)
    @edition = create(:edition,
                      created_by: @user)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_delete_the_draft
    @discard_request = stub_request(:post, %r{.*publishing-api.*/content/#{@edition.content_id}/discard-draft})
    click_on "Delete draft"
    click_on "Yes, delete draft"
  end

  def then_i_see_the_edition_is_gone
    expect(page).to have_current_path(documents_path, ignore_query: true)
    expect(page).not_to have_content @edition.title
  end

  def and_the_draft_is_discarded
    expect(@discard_request).to have_been_requested
  end
end
