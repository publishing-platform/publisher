require "rails_helper"

RSpec.describe "Publish without review", type: :system do
  scenario do
    given_there_is_a_draft_edition
    when_i_visit_the_summary_page
    and_after_i_have_created_a_preview
    and_i_publish_without_review
    then_i_see_the_publish_succeeded

    when_i_visit_the_summary_page
    then_i_see_it_has_not_been_reviewed

    when_i_click_the_approve_button
    then_i_see_that_its_reviewed
  end

  def given_there_is_a_draft_edition
    @creator = create(:user, email: "someone@example.com")

    @edition = create(:edition,
                      :publishable,
                      created_by: @creator,
                      base_path: "/news/banana-pricing-updates")
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_after_i_have_created_a_preview
    stub_request(:put, %r{.*publishing-api.*/content/#{@edition.content_id}})
    click_on "Preview"
    click_on "< Back"
  end

  def and_i_publish_without_review
    travel_to(@publish_time = Time.zone.now) do
      click_on "Publish"
      choose I18n.t!("publish.confirmation.should_be_reviewed")
      @publish_request = stub_request(:post, %r{.*publishing-api.*/content/#{@edition.content_id}/publish})
      click_on "Confirm publish"
    end
  end

  def then_i_see_the_publish_succeeded
    expect(@publish_request).to have_been_requested
    expect(page).to have_content(I18n.t!("publish.published.published_without_review.title"))
  end

  def then_i_see_it_has_not_been_reviewed
    expect(page).to have_content I18n.t!("user_facing_states.published_but_needs_2i.name")
  end

  def when_i_click_the_approve_button
    travel_to(@publish_time + 1.hour) do
      click_on "Approve"
    end
  end

  def then_i_see_that_its_reviewed
    expect(page).to have_content(I18n.t!("documents.show.flashes.approved"))
    expect(page).to have_content(I18n.t!("user_facing_states.published.name"))
  end
end
