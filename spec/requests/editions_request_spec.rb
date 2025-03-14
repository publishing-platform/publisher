require "rails_helper"

RSpec.describe "/documents/:document_id/editions", type: :request do
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  describe "POST /create" do
    let!(:edition) { create(:edition, :published) }

    it "redirects to edit edition path on success" do
      post create_edition_path(edition.document)
      expect(response).to redirect_to(edition_path(edition.document))
    end

    it "creates a new edition" do
      expect {
        post create_edition_path(edition.document)
      }.to change(Edition, :count).by(1)
    end

    it "returns 404 if document not found" do
      post create_edition_path({ document_id: "non-existent" })
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /edit" do
    let!(:edition) { create(:edition) }

    it "returns successfully" do
      get edition_path(edition.document)
      expect(response).to have_http_status(:ok)
    end

    it "renders a form for editing the draft edition content" do
      get edition_path(edition.document)

      assert_select "form[action='#{edition_path(edition.document)}']"
    end

    context "when a draft edition does not exist" do
      let!(:edition) { create(:edition, :published) }

      it "redirects to document summary page" do
        get edition_path(edition.document)
        expect(response).to redirect_to(document_path(edition.document))
      end
    end

    it "returns 404 if document not found" do
      post edition_path({ document_id: "non-existent" })
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /update" do
    let!(:edition) { create(:edition, summary: "Old summary") }

    it "redirects to to document summary page on success" do
      patch edition_path(edition.document), params: { summary: "New summary" }
      expect(response).to redirect_to(document_path(edition.document))
    end

    it "updates edition" do
      patch edition_path(edition.document), params: { summary: "New summary" }

      expect(edition.reload.summary).to eq("New summary")
    end

    it "returns issues and an unprocessable response when there are requirement issues" do
      patch edition_path(edition.document), params: { summary: "new\nline" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body)
        .to match(I18n.t!("requirements.summary.multiline.form_message"))
    end

    it "returns 404 if document not found" do
      patch edition_path({ document_id: "non-existent" }), params: { summary: "New summary" }
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /confirm_delete_draft" do
    let!(:edition) { create(:edition) }

    it "returns successfully" do
      get confirm_delete_draft_path(edition.document)
      expect(response).to have_http_status(:ok)
    end

    it "renders a form for confirming deletion of draft" do
      get confirm_delete_draft_path(edition.document)

      assert_select "form[action='#{destroy_draft_path(edition.document)}']"
    end

    it "returns 404 if document not found" do
      post confirm_delete_draft_path({ document_id: "non-existent" })
      expect(response).to have_http_status(:not_found)
    end

    context "when a draft edition does not exist" do
      let!(:edition) { create(:edition, :published) }

      it "redirects to document summary page" do
        get confirm_delete_draft_path(edition.document)
        expect(response).to redirect_to(document_path(edition.document))
      end
    end
  end

  describe "DELETE /destroy_draft" do
    let!(:edition) { create(:edition) }
    let!(:request) { stub_request(:post, %r{.*publishing-api.*/content/#{edition.content_id}/discard-draft}) }

    it "redirects to document index on success" do
      delete destroy_draft_path(edition.document)
      expect(response).to redirect_to(documents_path)
    end

    it "redirects to document summary when there is an API error" do
      request.to_return(status: 503)

      delete destroy_draft_path(edition.document)
      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to match(I18n.t!("documents.show.flashes.delete_draft_error"))
    end

    it "returns 404 if document not found" do
      delete destroy_draft_path({ document_id: "non-existent" })
      expect(response).to have_http_status(:not_found)
    end

    context "when a draft edition does not exist" do
      let!(:edition) { create(:edition, :published) }

      it "redirects to document summary page" do
        delete destroy_draft_path(edition.document)
        expect(response).to redirect_to(document_path(edition.document))
      end
    end
  end
end
