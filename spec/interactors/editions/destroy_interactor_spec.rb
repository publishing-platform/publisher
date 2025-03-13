require "rails_helper"

RSpec.describe Editions::DestroyInteractor do
  describe ".call" do
    let(:edition) { create(:edition) }
    let(:user) { create :user }
    let!(:request) { stub_request(:post, %r{.*publishing-api.*/content/.*/discard-draft}) }

    let(:params) do
      ActionController::Parameters.new(document_id: edition.document_id)
    end

    it "discards an edition" do
      result = described_class.call(params:, user:)
      expect(result).to be_success
      expect(result.edition).to be_discarded
    end

    it "delegates to the DiscardDraftEditionService" do
      expect(DiscardDraftEditionService)
        .to receive(:call)
        .with(edition, user)
      described_class.call(params:, user:)
    end

    context "when the Publishing API is down" do
      before { request.to_return(status: 503) }

      it "fails with an api_error flag" do
        result = described_class.call(params:, user:)
        expect(result).to be_failure
        expect(result.api_error).to be(true)
      end

      it "marks the edition as edition not synced" do
        result = described_class.call(params:, user:)
        expect(result.edition).not_to be_edition_synced
      end
    end

    context "when the edition isn't editable" do
      let(:edition) { create(:edition, :published) }

      it "raises a state error" do
        expect { described_class.call(params:, user:) }
          .to raise_error(EditionAssertions::StateError)
      end
    end
  end
end
