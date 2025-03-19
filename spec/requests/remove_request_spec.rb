require "rails_helper"

RSpec.describe "/documents/:document_id/remove", type: :request do
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  describe "GET /new" do
    it "returns sucessfully when edition is published" do
      edition = create(:edition, :published)
      get remove_path(edition.document)

      expect(response).to have_http_status(:ok)
    end

    it "returns sucessfully when edition is published but needs 2i" do
      edition = create(:edition, :published, state: "published_but_needs_2i")
      get remove_path(edition.document)

      expect(response).to have_http_status(:ok)
    end

    it "redirects to document summary page for a draft edition" do
      edition = create(:edition)
      get remove_path(edition.document)
      expect(response).to redirect_to(document_path(edition.document))
    end

    it "returns 404 if document not found" do
      get remove_path({ document_id: "non-existent" })
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    let(:edition) { create(:edition, :published) }
    let!(:request) { stub_request(:post, %r{.*publishing-api.*/content/#{edition.content_id}/unpublish}) }

    it "redirects to document summary page on success" do
      post remove_path(edition.document)
      expect(response).to redirect_to(document_path(edition.document))
    end

    it "returns issues and an unprocessable response when there are requirement issues" do
      post remove_path(edition.document),
           params: { redirect_url: "invalid" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to match(
        I18n.t!("requirements.redirect_url.invalid.form_message"),
      )
    end

    it "returns a service unavailable response with error when Publishing API is unavailable" do
      request.to_return(status: 503)

      post remove_path(edition.document)

      expect(response).to have_http_status(:service_unavailable)
      expect(response.body).to match(
        I18n.t!("remove.new.flashes.publishing_api_error"),
      )
    end

    it "returns 404 if document not found" do
      get remove_path({ document_id: "non-existent" })
      expect(response).to have_http_status(:not_found)
    end
  end
end
