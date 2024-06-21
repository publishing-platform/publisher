class PreviewController < ApplicationController
  def create
  end

  def show
    @edition = Edition.find_current(params[:document_id])
    assert_edition_state(@edition, assertion: "not live") { !@edition.live? }    
  end
end