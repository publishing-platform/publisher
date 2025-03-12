require "rails_helper"

RSpec.describe EditDraftEditionService do
  describe ".call" do
    let(:edition) { build(:edition, edition_synced: true) }
    let(:user) { build(:user) }

    it "assigns attributes to an edition" do
      expect { described_class.call(edition, user, created_by: user) }
        .to change(edition, :created_by).to(user)
    end

    it "does not save the edition" do
      described_class.call(edition, user, {})

      expect(edition).to be_new_record
    end

    it "updates who edited it" do
      expect { described_class.call(edition, user, {}) }
        .to change(edition, :last_edited_by).to(user)
    end

    it "raises an error if a live edition is edited" do
      live_edition = build(:edition, live: true)

      expect { described_class.call(live_edition, user, {}) }
        .to raise_error("cannot edit a live edition")
    end

    describe "updates sync flag" do
      it "flags the edition as out-of-sync" do
        expect { described_class.call(edition, user, {}) }
          .to change(edition, :edition_synced).to(false)
      end
    end
  end
end
