require "rails_helper"

RSpec.describe CreateDocumentService do
  describe ".call" do
    let(:document_type) { build(:document_type) }
    let(:user) { create(:user) }

    it "creates a document" do
      expect { described_class.call(document_type_id: document_type.id, user:) }
        .to change(Document, :count).by(1)
    end

    it "runs inside a transaction so failures are rolled back" do
      expect(Document).to receive(:transaction)
      described_class.call(document_type_id: document_type.id, user:)
    end

    it "sets the document to have a draft current edition for the appropriate document type" do
      document = described_class.call(document_type_id: document_type.id, user:)
      expect(document.current_edition).to be_draft
      expect(document.current_edition.document_type).to eq(document_type)
    end

    it "sets the number of the first edition accordingly" do
      document = described_class.call(document_type_id: document_type.id, user:)
      expect(document.current_edition.number).to be(1)
    end

    it "sets the initial update type" do
      document = described_class.call(document_type_id: document_type.id, user:)
      expect(document.current_edition.update_type).to eq("major")
    end

    it "sets the initial state" do
      document = described_class.call(document_type_id: document_type.id, user:)
      expect(document.current_edition.state).to eq("draft")
    end

    it "is attributed to a user" do
      document = described_class.call(document_type_id: document_type.id,
                                      user:)

      expect(document.created_by).to eq(user)
      expect(document.current_edition.created_by).to eq(user)
      expect(document.current_edition.last_edited_by).to eq(user)
    end
  end
end
