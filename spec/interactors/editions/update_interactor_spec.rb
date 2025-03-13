require "rails_helper"

RSpec.describe Editions::UpdateInteractor do
  describe ".call" do
    let(:edition) { create(:edition, number: 2) }
    let(:user) { build(:user) }

    let(:params) do
      ActionController::Parameters.new(document_id: edition.document_id,
                                       summary: "New summary",
                                       change_note: "New note",
                                       update_type: "minor")
    end

    it "succeeds with default parameters" do
      result = described_class.call(params:, user:)
      expect(result).to be_success
    end

    it "updates the edition" do
      expect { described_class.call(params:, user:) }
        .to change { edition.reload.summary }.to("New summary")
        .and change { edition.reload.change_note }.to("New note")
        .and change { edition.reload.update_type }.to("minor")
    end

    it "raises an error when the edition isn't editable" do
      params.merge!(document_id: create(:edition, :published).document_id)

      expect { described_class.call(params:, user:) }
        .to raise_error(EditionAssertions::StateError)
    end

    it "fails if there are issues with the input" do
      params.merge!(summary: "new\nline")
      result = described_class.call(params:, user:)
      expect(result).to be_failure
      expect(result.issues).to have_issue(:summary, :multiline)
    end
  end
end
