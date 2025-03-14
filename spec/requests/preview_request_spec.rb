require "rails_helper"

RSpec.describe "/documents/:document_id/preview", type: :request do
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  describe "GET /show" do
    let(:edition) { create(:edition) }

    it "returns successfully with an editable edition" do
      get preview_document_path(edition.document)
      expect(response).to have_http_status(:ok)
    end

    context "when a draft edition does not exist" do
      let(:edition) { create(:edition, :published) }

      it "redirects to document summary page" do
        get edition_path(edition.document)
        expect(response).to redirect_to(document_path(edition.document))
      end
    end

    it "returns 404 if document not found" do
      get edition_path({ document_id: "non-existent" })
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /create" do
    let(:edition) { create(:edition) }
    let!(:request) { stub_request(:put, %r{.*publishing-api.*/content/#{edition.content_id}}) }

    it "redirects to the preview page on success" do
      post preview_path(edition.document)

      expect(response).to redirect_to(preview_document_path(edition.document))
    end

    context "when there are preview issues" do
      let(:document_type) { build(:document_type, contents: [DocumentType::TitleAndBasePathField.new]) }
      let(:edition) { create(:edition, document_type:, title: "", edition_synced: false) }

      it "redirects to the document summary page displaying issues" do
        post preview_path(edition.document)

        expect(response).to redirect_to(document_path(edition.document))
        follow_redirect!

        assert_select ".alert-danger", text: /#{I18n.t!('requirements.title.blank.summary_message')}/
      end
    end

    it "redirects to document summary when there is an API error" do
      request.to_return(status: 503)

      post preview_path(edition.document)
      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to match(I18n.t!("documents.show.flashes.preview_error"))
    end
  end
end
