require "rails_helper"

RSpec.describe "/documents/:document_id", type: :request do
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  describe "POST /submit-for-2i" do
    it "redirects to document summary on success" do
      edition = create(:edition, :publishable)
      post submit_for_2i_path(edition.document)
      expect(response).to redirect_to(document_path(edition.document))
    end

    it "updates state on success" do
      edition = create(:edition, :publishable)
      post submit_for_2i_path(edition.document)
      expect(edition.reload.submitted_for_review?).to be true
    end

    it "redirects to document summary in an error when edition isn't publishable" do
      edition = create(:edition, summary: "")
      post submit_for_2i_path(edition.document)

      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      assert_select ".alert-danger", text: /#{I18n.t!('requirements.summary.blank.summary_message')}/
    end

    context "when a draft edition does not exist" do
      let(:edition) { create(:edition, :published) }

      it "redirects to document summary page" do
        post submit_for_2i_path(edition.document)
        expect(response).to redirect_to(document_path(edition.document))
      end

      it "does not change state" do
        post submit_for_2i_path(edition.document)
        expect(edition.reload.published?).to be true
      end
    end

    it "returns 404 if document not found" do
      post submit_for_2i_path({ document_id: "non-existent" })
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /approve" do
    it "redirects to document summary with notification on success" do
      edition = create(:edition, :published_but_needs_2i)
      post approve_path(edition.document)
      expect(response).to redirect_to(document_path(edition.document))
      follow_redirect!
      expect(response.body)
        .to match(I18n.t!("documents.show.flashes.approved"))
    end

    it "updates state on success" do
      edition = create(:edition, :published_but_needs_2i)
      post approve_path(edition.document)
      expect(edition.reload.published?).to be true
    end

    context "when edition is draft" do
      let(:edition) { create(:edition) }

      it "redirects to document summary page" do
        post approve_path(edition.document)
        expect(response).to redirect_to(document_path(edition.document))
      end

      it "does not change state" do
        post approve_path(edition.document)
        expect(edition.reload.draft?).to be true
      end
    end

    it "returns 404 if document not found" do
      post approve_path({ document_id: "non-existent" })
      expect(response).to have_http_status(:not_found)
    end
  end
end
