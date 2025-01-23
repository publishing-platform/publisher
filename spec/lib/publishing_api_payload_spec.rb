require "rails_helper"

RSpec.describe PublishingApiPayload do
  describe "#payload" do
    it "generates a payload for the publishing API" do
      document_type = build(:document_type)
      edition = build(:edition, document_type:)

      payload = described_class.new(edition).payload

      payload_hash = {
        schema_name: nil,
        document_type: document_type.id,
        publishing_app: "publisher",
        rendering_app: nil,
        update_type: "major",
      }
      expect(payload).to match a_hash_including(payload_hash)
      expect(payload).not_to include(:first_published_at)
    end

    it "includes a public_updated_at timestamp for draft editions" do
      freeze_time do
        edition = build(:edition)

        payload = described_class.new(edition).payload

        payload_hash = {
          public_updated_at: Time.zone.now,
        }

        expect(payload).to match a_hash_including(payload_hash)
      end
    end

    it "includes a first_published_at and public_updated_at timestamp for published editions" do
      edition = build(:edition, :published, first_published_at: "2020-02-20 08:00:00")

      payload = described_class.new(edition).payload

      payload_hash = {
        first_published_at: Time.zone.parse("2020-02-20 08:00:00"),
        public_updated_at: Time.zone.parse("2020-02-20 08:00:00"),
      }

      expect(payload).to match a_hash_including(payload_hash)
    end

    it "delegates to PublishingApiPayload::History to populate change_history" do
      history = instance_double(
        PublishingApiPayload::History,
        change_history: [{ note: "note", public_timestamp: Time.zone.now }],
        public_updated_at: Time.zone.now,
        first_published_at: Time.zone.now,
      )
      allow(PublishingApiPayload::History).to receive(:new).and_return(history)

      payload = described_class.new(build(:edition)).payload

      expect(payload[:details][:change_history]).to match(history.change_history)
    end

    it "specifies an auth bypass ID for anonymous previews" do
      edition = build(:edition)
      payload = described_class.new(edition).payload
      expect(payload[:auth_bypass_ids]).to eq([edition.auth_bypass_id])
    end

    it "delegates to document type fields for contents" do
      body_field = instance_double(DocumentType::BodyField,
                                   payload: { details: { body: "body" } })

      document_type = build(:document_type, contents: [body_field])
      edition = build(:edition, document_type:)
      payload = described_class.new(edition).payload
      expect(payload[:details][:body]).to eq("body")
    end
  end
end
