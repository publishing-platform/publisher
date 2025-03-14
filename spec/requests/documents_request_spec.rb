require "rails_helper"

RSpec.describe "/documents", type: :request do
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  describe "GET /index" do
    it "renders list of document editions" do
      create(:edition, title: "test edition")
      get documents_path

      expect(response).to have_http_status(:ok)
      assert_select "table tr td:nth-child(1)", /test edition/
    end

    it "only lists current editions" do
      document = create(:document, :live)

      document.live_edition = create(
        :edition,
        :published,
        title: "live edition",
        created_by: document.created_by,
        current: false,
        document:,
      )

      document.current_edition = create(
        :edition,
        title: "current edition",
        created_by: document.created_by,
        document:,
      )

      get documents_path

      assert_select "table tr td:nth-child(1)", /current edition/
      assert_select "table tr td:nth-child(1)", text: /live edition/, count: 0
    end

    it "renders link to create a new document" do
      get documents_path

      assert_select "a[href='#{new_document_path}']", text: "Create new document"
    end

    context "when filtering" do
      it "filters by partially matching title" do
        create(:edition, title: "does-match1")
        create(:edition, title: "does-match2")
        create(:edition, title: "does-not-match")

        get documents_path, params: { title_or_url: "does-match" }

        assert_select "table tr td:nth-child(1)", text: /does-match/, count: 2
        assert_select "table tr td:nth-child(1)", text: /does-not-match/, count: 0
      end

      it "filters by partially matching base path" do
        create(:edition, title: "document-1", base_path: "/does-match1")
        create(:edition, title: "document-2", base_path: "/does-match2")
        create(:edition, title: "document-3", base_path: "/does-not-match")

        get documents_path, params: { title_or_url: "does-match" }

        assert_select "table tr td:nth-child(1)", text: /document-1/
        assert_select "table tr td:nth-child(1)", text: /document-2/
        assert_select "table tr td:nth-child(1)", text: /document-3/, count: 0
      end

      it "filters by document type" do
        answer = DocumentType.find("answer")

        create(:edition, title: "does-match1", document_type: answer)
        create(:edition, title: "does-match2", document_type: answer)
        create(:edition, title: "does-not-match", document_type: create(:document_type))

        get documents_path, params: { document_type: answer.id }

        assert_select "table tr td:nth-child(1)", text: /does-match/, count: 2
        assert_select "table tr td:nth-child(1)", text: /does-not-match/, count: 0
      end

      it "filters by state" do
        create(:edition, title: "does-match1", state: "draft")
        create(:edition, title: "does-not-match", state: "published")
        create(:edition, title: "does-not-match", state: "published")

        get documents_path, params: { state: "draft" }

        assert_select "table tr td:nth-child(1)", text: /does-match/, count: 1
        assert_select "table tr td:nth-child(1)", text: /does-not-match/, count: 0
      end

      it "displays link to clear all filters" do
        get documents_path
        assert_select "a", text: "Clear all filters", href: documents_path
      end
    end
  end

  describe "GET /new" do
    it "renders a form allowing the user to select the content type of the new document" do
      answer = DocumentType.find("answer")

      get new_document_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("What is the content for?")

      assert_select "form[action='#{documents_path}']" do
        assert_select "input[type='radio'][name='document_type'][id='document_type_#{answer.id}'][value='#{answer.id}']"
      end
    end
  end

  describe "POST /create" do
    it "redirects to edit edition path on success" do
      post documents_path, params: { document_type: "answer" }

      expect(response).to redirect_to(edition_path(Document.last))
      follow_redirect!
      expect(response.body).to include("answer")
    end

    it "returns an unprocessable response with an issue when a document type isn't selected" do
      post documents_path, params: {}

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include(
        I18n.t("requirements.document_type.not_selected.form_message"),
      )
    end
  end

  describe "GET /show" do
    let(:document) { create(:document) }

    it "returns successfully" do
      create(:edition, document:)

      get document_path(document)
      expect(response).to have_http_status(:ok)
    end

    context "when edition is draft" do
      let(:edition) { create(:edition, document:) }

      it "renders a link to edit the edition content" do
        get document_path(edition.document)
        assert_select "a[href='#{edition_path(edition.document)}']", text: "Edit"
      end

      it "renders a link to delete the edition" do
        get document_path(edition.document)
        assert_select "a[href='#{confirm_delete_draft_path(edition.document)}']", text: "Delete draft"
      end

      it "renders a form to create edition preview" do
        get document_path(edition.document)
        assert_select "form[action='#{preview_document_path(edition.document)}'] input[type='submit'][value='Preview']"
      end

      it "does not render a form to create a new draft edition" do
        get document_path(edition.document)
        assert_select "form[action='#{create_edition_path(edition.document)}'] input[type='submit'][value='Create new edition']", count: 0
      end

      context "and edition is synced" do
        before do
          edition.update!(edition_synced: true)
        end

        it "renders a form to submit edition for 2i review" do
          get document_path(edition.document)
          assert_select "form[action='#{submit_for_2i_path(edition.document)}'] input[type='submit'][value='Submit for 2i review']"
        end

        it "renders a link to preview the edition" do
          get document_path(edition.document)
          assert_select "a[href='#{preview_document_path(edition.document)}']", text: "Preview"
        end

        it "renders a link to publish the edition" do
          get document_path(edition.document)
          assert_select "a[href='#{publish_confirmation_path(edition.document)}']", text: "Publish"
        end
      end
    end

    context "when edition is submitted for review" do
      let(:edition) { create(:edition, document:, state: "submitted_for_review") }

      it "renders a link to publish the edition" do
        get document_path(edition.document)
        assert_select "a[href='#{publish_confirmation_path(edition.document)}']", text: "Publish"
      end

      it "renders a link to delete the edition" do
        get document_path(edition.document)
        assert_select "a[href='#{confirm_delete_draft_path(edition.document)}']", text: "Delete draft"
      end
    end

    context "when edition is removed" do
      let(:edition) { create(:edition, document:, state: "removed") }

      it "renders a form to create a new draft edition" do
        get document_path(edition.document)
        assert_select "form[action='#{create_edition_path(edition.document)}'] input[type='submit'][value='Create new edition']"
      end
    end

    context "when edition is published" do
      let(:edition) { create(:edition, :published) }

      it "renders a form to create a new draft edition" do
        get document_path(edition.document)
        assert_select "form[action='#{create_edition_path(edition.document)}'] input[type='submit'][value='Create new edition']"
      end

      it "renders a link to remove the edition" do
        get document_path(edition.document)
        assert_select "a[href='#{remove_path(edition.document)}']", text: "Remove"
      end

      it "does not render a link to delete the edition" do
        get document_path(edition.document)
        assert_select "a[href='#{confirm_delete_draft_path(edition.document)}']", text: "Delete draft", count: 0
      end

      it "does not render a link to publish the edition" do
        get document_path(edition.document)
        assert_select "a[href='#{publish_confirmation_path(edition.document)}']", text: "Publish", count: 0
      end
    end

    context "when edition is published but needs 2i" do
      let(:edition) { create(:edition, :published, state: "published_but_needs_2i") }

      it "renders a form to approve edition" do
        get document_path(edition.document)
        assert_select "form[action='#{approve_path(edition.document)}'] input[type='submit'][value='Approve']"
      end

      it "renders a form to create a new draft edition" do
        get document_path(edition.document)
        assert_select "form[action='#{create_edition_path(edition.document)}'] input[type='submit'][value='Create new edition']"
      end

      it "renders a link to remove the edition" do
        get document_path(edition.document)
        assert_select "a[href='#{remove_path(edition.document)}']", text: "Remove"
      end

      it "does not render a link to delete the edition" do
        get document_path(edition.document)
        assert_select "a[href='#{confirm_delete_draft_path(edition.document)}']", text: "Delete draft", count: 0
      end

      it "does not render a link to publish the edition" do
        get document_path(edition.document)
        assert_select "a[href='#{publish_confirmation_path(edition.document)}']", text: "Publish", count: 0
      end
    end

    it "returns 404 if document not found" do
      get document_path({ document_id: "non-existent" })
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /generate-path" do
    it "returns a text response of a path" do
      edition = create(:edition, title: "A title")
      get generate_path_path(edition.document, title: "A title")

      expect(response).to have_http_status(:ok)
      expect(response.media_type).to eq("text/plain")
      expect(response.body).to match("/a-title")
    end

    it "returns 404 if document not found" do
      get generate_path_path({ document_id: "non-existent" })
      expect(response).to have_http_status(:not_found)
    end
  end
end
