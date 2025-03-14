require "rails_helper"

RSpec.describe "/documents/:document_id/publish", type: :request do
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  describe "GET /confirmation" do
    it "returns sucessfully when edition is publishable" do
      edition = create(:edition, :publishable)
      get publish_confirmation_path(edition.document)

      expect(response).to have_http_status(:ok)
      expect(response.body)
        .to match(I18n.t!("publish.confirmation.title"))
    end

    context "when there are publish issues" do
      let(:edition) { create(:edition, summary: "") }

      it "redirects to the document summary page displaying issues" do
        get publish_confirmation_path(edition.document)

        expect(response).to redirect_to(document_path(edition.document))
        follow_redirect!

        assert_select ".alert-danger", text: /#{I18n.t!('requirements.summary.blank.summary_message')}/
      end
    end

    context "when a draft edition does not exist" do
      let(:edition) { create(:edition, :published) }

      it "redirects to document summary page" do
        get publish_confirmation_path(edition.document)
        expect(response).to redirect_to(document_path(edition.document))
      end
    end

    it "returns 404 if document not found" do
      get publish_confirmation_path({ document_id: "non-existent" })
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /publish" do
    let(:edition) { create(:edition, :publishable) }
    let!(:request) { stub_request(:post, %r{.*publishing-api.*/content/#{edition.content_id}/publish}) }

    it "redirects to a success page when publishing is successful" do
      post publish_path(edition.document),
           params: { review_status: "reviewed" }

      expect(response).to redirect_to(published_path(edition.document))
      expect(edition.reload.published?).to be true
    end

    context "when there are publish issues" do
      let(:edition) { create(:edition, summary: "") }

      it "redirects to the document summary page" do
        post publish_path(edition.document),
             params: { review_status: "reviewed" }

        expect(response).to redirect_to(document_path(edition.document))
        expect(edition.reload.published?).to be false
      end
    end

    it "returns an unprocessable response with an issue when a review status isn't provided" do
      post publish_path(edition.document),
           params: { review_status: "" }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to match(
        I18n.t!("requirements.review_status.not_selected.form_message"),
      )
    end

    it "redirects to document summary when there is an API error" do
      request.to_return(status: 503)

      post publish_path(edition.document),
           params: { review_status: "reviewed" }

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to match(I18n.t!("documents.show.flashes.publish_error"))
    end

    it "returns 404 if document not found" do
      post publish_path({ document_id: "non-existent" })
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /published" do
    it "returns successfully when edition is published" do
      edition = create(:edition, :published)
      get published_path(edition.document)

      expect(response).to have_http_status(:ok)
      expect(response.body)
        .to match(I18n.t!("publish.published.reviewed.title"))
    end

    it "returns successfully when edition is published but needs 2i" do
      edition = create(:edition, :published, state: :published_but_needs_2i)
      get published_path(edition.document)

      expect(response).to have_http_status(:ok)
      expect(response.body).to match(
        I18n.t!("publish.published.published_without_review.title"),
      )
    end

    context "when a published edition does not exist" do
      let(:edition) { create(:edition) }

      it "redirects to document summary page" do
        get published_path(edition.document)
        expect(response).to redirect_to(document_path(edition.document))
      end
    end

    it "returns 404 if document not found" do
      get published_path({ document_id: "non-existent" })
      expect(response).to have_http_status(:not_found)
    end
  end
end
