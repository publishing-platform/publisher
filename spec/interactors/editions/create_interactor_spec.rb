require "rails_helper"

RSpec.describe Editions::CreateInteractor do
  describe ".call" do
    let(:user) { create(:user) }
    let(:edition) do
      create(:edition,
             live: true,
             change_note: "note",
             update_type: :minor)
    end
    let(:params) { { document_id: edition.document_id } }

    it "resets the edition metadata" do
      next_edition = described_class
        .call(params:, user:)
        .next_edition

      expect(next_edition.update_type).to eq "major"
      expect(next_edition.change_note).to be_empty
      expect(next_edition).to be_draft
      expect(next_edition).to be_current
    end

    it "delegates to the CreateNextEditionService" do
      expect(CreateNextEditionService)
        .to receive(:call)
        .with(current_edition: edition, user:)
        .and_call_original

      described_class.call(params:, user:)
    end
  end
end
