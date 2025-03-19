require "rails_helper"

RSpec.describe "Index details", type: :system do
  let(:created_at) { Time.zone.local(2025, 3, 13, 3, 10, 45) }

  before do
    travel_to created_at
  end

  after do
    travel_back
  end

  scenario do
    given_there_is_an_edition
    when_i_visit_the_index_page
    then_i_can_see_the_edition
  end

  def given_there_is_an_edition
    @edition = create(:edition)
  end

  def when_i_visit_the_index_page
    visit documents_path
  end

  def then_i_can_see_the_edition
    expect(page).to have_content(@edition.title)
    expect(page).to have_content(@edition.document_type.label)
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))
    expect(page).to have_content(created_at.to_fs(:time_on_date))
  end
end
