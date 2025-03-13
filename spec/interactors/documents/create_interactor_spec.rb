require "rails_helper"

RSpec.describe Documents::CreateInteractor do
  describe ".call" do
    let(:user) { build(:user) }

    it "succeeds with valid parameters" do
      result = described_class.call(params: { document_type: "answer" }, user:)
      expect(result).to be_success
    end

    it "creates a new document" do
      expect { described_class.call(params: { document_type: "answer" }, user:) }
        .to change(Document, :count)
        .by(1)
    end

    it "fails if the document_type isn't passed" do
      result = described_class.call(params: {}, user:)
      expect(result).not_to be_success
    end

    it "returns the document types" do
      document_types = DocumentType.all

      result = described_class.call(params: { document_type: "answer" }, user:)
      expect(result.document_types).to eq(document_types)
    end

    it "returns the selected document type" do
      result = described_class.call(params: { document_type: "answer" }, user:)
      expect(result.document_type).to eq("answer")
    end
  end
end
