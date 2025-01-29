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

  # describe "POST /create" do
  # end

  # describe "GET /show" do
  # end

  # describe "GET /generate-path" do
  # end
end
