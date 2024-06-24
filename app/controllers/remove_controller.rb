class RemoveController < ApplicationController
  def new
    @edition = Edition.find_current(params[:document_id])

    assert_edition_state(@edition, assertion: "is published") do
      @edition.published? || @edition.published_but_needs_2i?
    end
  end

  def create
    result = Remove::CreateInteractor.call(params:, user: current_user)
  end
end