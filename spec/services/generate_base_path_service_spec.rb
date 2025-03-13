require "rails_helper"

RSpec.describe GenerateBasePathService do
  describe ".call" do
    let(:document_type) { build(:document_type, path_prefix: "/prefix") }
    let(:edition) { create(:edition, document_type:) }

    it "copes if the proposed title is nil or blank" do
      prefix = edition.document_type.path_prefix
      expect(described_class.call(edition, title: nil)).to eq("#{prefix}/")
      expect(described_class.call(edition, title: " ")).to eq("#{prefix}/")
    end

    it "preserves the base path when the title does not change" do
      prefix = edition.document_type.path_prefix
      expect(described_class.call(edition, title: edition.title))
        .to eq("#{prefix}#{edition.base_path}")
    end
  end
end
