require "rails_helper"

RSpec.describe "Publishing an edition", type: :system do
  scenario do
    given_there_is_a_draft_edition
    when_i_visit_the_summary_page
    and_after_i_have_created_a_preview
    and_i_publish_the_edition
    then_i_see_the_publish_succeeded
    and_the_content_is_shown_as_published
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

  def and_i_publish_the_edition
    travel_to(@publish_time = Time.zone.now) do
      click_on "Publish"
      choose I18n.t!("publish.confirmation.has_been_reviewed")
      @publish_request = stub_request(:post, %r{.*publishing-api.*/content/#{@edition.content_id}/publish})
      click_on "Confirm publish"
    end
  end

  def then_i_see_the_publish_succeeded
    expect(@publish_request).to have_been_requested
    expect(page).to have_content(I18n.t!("publish.published.reviewed.title"))
  end

  def and_the_content_is_shown_as_published
    visit document_path(@edition.document)
    expect(page).to have_content(I18n.t!("user_facing_states.published.name"))
    expect(page).to have_link("View on Publishing Platform", href: "https://www.test.publishing-platform.co.uk/news/banana-pricing-updates")
  end
end
