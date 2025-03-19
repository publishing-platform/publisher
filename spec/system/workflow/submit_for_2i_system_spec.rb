require "rails_helper"

RSpec.describe "Submit for 2i", type: :system do
  scenario do
    given_there_is_a_draft_edition
    when_i_visit_the_summary_page
    and_after_i_have_created_a_preview
    and_i_click_submit_for_2i
    then_i_see_the_edition_is_submitted
  end

  def given_there_is_a_draft_edition
    @edition = create(:edition, :publishable)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_after_i_have_created_a_preview
    stub_request(:put, %r{.*publishing-api.*/content/#{@edition.content_id}})
    click_on "Preview"
    click_on "< Back"
  end

  def and_i_click_submit_for_2i
    click_on "Submit for 2i review"
  end

  def then_i_see_the_edition_is_submitted
    expect(page).to have_content I18n.t!("user_facing_states.submitted_for_review.name")
  end
end
