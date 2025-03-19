require "rails_helper"

RSpec.describe "Remove a document", type: :system do
  scenario do
    given_there_is_a_published_edition
    when_i_visit_the_summary_page
    and_i_click_on_remove
    and_i_fill_in_the_redirect_url
    and_i_confirm_the_removal
    then_i_see_the_document_has_been_removed
  end

  def given_there_is_a_published_edition
    @edition = create(:edition, :published)
  end

  def when_i_visit_the_summary_page
    visit document_path(@edition.document)
  end

  def and_i_click_on_remove
    click_on "Remove"
  end

  def and_i_fill_in_the_redirect_url
    @path = "/redirect-to-page"
    @url = "https://www.publishing-platform.co.uk/#{@path}"
    fill_in "redirect_url", with: @url
  end

  def and_i_confirm_the_removal
    params = {
      body: {
        type: "redirect",
        alternative_path: @path,
        discard_drafts: true,
      },
    }
    stub_request(:post, %r{.*publishing-api.*/content/#{@edition.content_id}/unpublish}).with(params)
    click_on "Remove document"
  end

  def then_i_see_the_document_has_been_removed
    expect(page).to have_content(I18n.t!("user_facing_states.removed.name"))
  end
end
