require "rails_helper"

RSpec.describe CreateNextEditionService do
  describe ".call" do
    let(:user) { create :user }

    it "aborts if the current edition isn't live" do
      current_edition = create(:edition, live: false)

      expect { described_class.call(current_edition:, user:) }
        .to raise_error("Can only create a next edition from a live edition")
    end

    it "returns a new current edition" do
      current_edition = create(:edition, :published, number: 2)

      next_edition = described_class.call(current_edition:,
                                          user:)

      expect(current_edition).not_to be_current
      expect(next_edition).to be_current
    end

    it "updates the edition number of the new current edition" do
      current_edition = create(:edition, :published, number: 2)

      next_edition = described_class.call(current_edition:,
                                          user:)

      expect(next_edition.number).to eq 3
      expect(next_edition.created_by).to eq user
    end

    it "returns a draft edition" do
      current_edition = create(:edition, :published)

      next_edition = described_class.call(current_edition:,
                                          user:)

      expect(next_edition).to be_draft
    end

    it "resets change_note and update_type values" do
      current_edition = create(:edition,
                               :published,
                               change_note: "note",
                               update_type: "minor")

      next_edition = described_class.call(current_edition:,
                                          user:)

      expect(next_edition.change_note).to be_empty
      expect(next_edition.update_type).to eq("major")
    end

    it "appends the change note details when there is a change note and a major change" do
      current_edition = create(:edition,
                               :published,
                               number: 2,
                               published_at: Date.yesterday.noon,
                               change_note: "note",
                               update_type: "major")

      next_edition = described_class.call(current_edition:,
                                          user:)

      expect(next_edition.change_history.first).to match a_hash_including(
        "note" => "note",
        "public_timestamp" => Date.yesterday.noon.rfc3339,
      )
    end

    it "does not update the change history when the current edition is not a major change" do
      current_edition = create(:edition,
                               :published,
                               number: 2,
                               published_at: Date.yesterday.noon,
                               change_note: "note",
                               update_type: "minor")

      next_edition = described_class.call(current_edition:,
                                          user:)

      expect(next_edition.change_history).to eq(current_edition.change_history)
    end

    it "does not update the change history when the current edition lacks a change note" do
      current_edition = create(:edition,
                               :published,
                               number: 2,
                               change_note: nil)

      next_edition = described_class.call(current_edition:,
                                          user:)

      expect(next_edition.change_history).to be_empty
    end

    context "when the current edition is the first edition" do
      it "doesn't append the change note details" do
        current_edition = create(:edition,
                                 :published,
                                 change_note: "note")

        next_edition = described_class.call(current_edition:,
                                            user:)

        expect(next_edition.change_history).to eq(current_edition.change_history)
      end
    end
  end
end
