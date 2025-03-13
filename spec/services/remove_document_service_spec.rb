require "rails_helper"

RSpec.describe RemoveDocumentService do
  describe "#call" do
    let(:user) { build(:user) }
    let(:edition) { create(:edition, :published) }
    let(:redirect_url) { nil }
    let!(:request) { stub_request(:post, %r{.*publishing-api.*/content/#{edition.content_id}/unpublish}) }

    it "calls the Publishing API unpublish method" do
      request.with({
        body: hash_including(type: "gone"),
      })

      described_class.call(edition, user, redirect_url:)
      expect(request).to have_been_requested
    end

    it "updates the edition status" do
      expect { described_class.call(edition, user, redirect_url:) }
        .to change(edition, :state)
        .to("removed")
    end

    it "updates edition last edited by" do
      described_class.call(edition, user, redirect_url:)
      expect(edition.last_edited_by).to eq(user)
    end

    context "when the removal is a redirect" do
      let(:redirect_url) { "/redirect-url" }

      it "unpublishes in the Publishing API with a type of redirect" do
        request.with({
          body: hash_including(type: "redirect", alternative_path: redirect_url, discard_drafts: true),
        })

        described_class.call(edition, user, redirect_url:)
        expect(request).to have_been_requested
      end
    end

    context "when Publishing API is down" do
      before { request.to_return(status: 503) }

      it "doesn't change the editions state" do
        expect { described_class.call(edition, user, redirect_url:) }
          .to raise_error(PublishingPlatformApi::BaseError)
        expect(edition.reload.state).to eq("published")
      end
    end

    context "when the given edition is a draft" do
      let(:edition) { create(:edition) }

      it "raises an error" do
        expect { described_class.call(edition, user, redirect_url:) }
          .to raise_error "attempted to remove an edition other than the live edition"
      end
    end
  end
end
