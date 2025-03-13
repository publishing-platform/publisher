require "rails_helper"

RSpec.describe PreviewDraftEditionService do
  let(:edition) { create(:edition) }
  let!(:request) { stub_request(:put, %r{.*publishing-api.*/content/#{edition.content_id}}) }

  describe ".call" do
    it "updates the Publishing API" do
      described_class.call(edition)
      expect(request).to have_been_requested
    end

    context "with unsynced edition" do
      let(:edition) { create(:edition, edition_synced: false) }

      it "marks the edition as 'edition_synced'" do
        described_class.call(edition)
        expect(edition.reload.edition_synced).to be(true)
      end
    end

    it "sets an update type of republish" do
      expect(PublishingApiPayload)
        .to receive(:new)
        .with(edition, republish: true)
        .and_call_original

      described_class.call(edition, republish: true)
    end

    # context "when Publishing API is down" do
    #   let(:edition) { create(:edition, edition_synced: true) }

    #   before { request.to_return(status: 503) }

    #   it "sets edition_synced to false on the edition" do
    #     expect { described_class.call(edition) }.to raise_error(PublishingPlatformApi::BaseError)
    #     expect(edition.edition_synced).to be(false)
    #   end
    # end
  end
end
