require "rails_helper"

RSpec.describe Edition do
  describe "#auth_bypass_token" do
    let(:edition) { create(:edition) }

    around { |example| freeze_time { example.run } }

    def decoded_token_payload(token)
      payload, _header = JWT.decode(
        token,
        Rails.application.credentials.jwt_auth_secret,
        true,
        { algorithm: "HS256" },
      )

      payload
    end

    it "returns a token with a sub of the auth_bypass_id" do
      payload = decoded_token_payload(edition.auth_bypass_token)
      expect(payload["sub"]).to eq(edition.auth_bypass_id)
    end

    it "returns a token with the edition's content_id" do
      payload = decoded_token_payload(edition.auth_bypass_token)
      expect(payload["content_id"]).to eq(edition.content_id)
    end

    it "returns a token issued at the current time" do
      payload = decoded_token_payload(edition.auth_bypass_token)
      expect(payload["iat"]).to eq(Time.zone.now.to_i)
    end

    it "returns a token that expires in 1 month" do
      payload = decoded_token_payload(edition.auth_bypass_token)
      expect(payload["exp"]).to eq(1.month.from_now.to_i)
    end
  end
end
