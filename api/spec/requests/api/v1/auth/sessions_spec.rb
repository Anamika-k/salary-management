require "rails_helper"

RSpec.describe "Auth sessions", type: :request do
  let!(:user) { create(:user, email: "hr@acme.test", password: "Secret123!") }

  def sign_in_as(email:, password:)
    post "/api/v1/auth/sign_in", params: { user: { email:, password: } }, as: :json
  end

  describe "POST /api/v1/auth/sign_in" do
    it "returns a bearer token and the user for valid credentials" do
      sign_in_as(email: "hr@acme.test", password: "Secret123!")

      expect(response).to have_http_status(:ok)
      expect(response.headers["Authorization"]).to start_with("Bearer ")
      expect(response.parsed_body["user"]).to eq("id" => user.id, "name" => user.name, "email" => user.email)
    end

    it "accepts the email in any case" do
      sign_in_as(email: "HR@ACME.TEST", password: "Secret123!")
      expect(response).to have_http_status(:ok)
    end

    it "never exposes password data" do
      sign_in_as(email: "hr@acme.test", password: "Secret123!")
      expect(response.body).not_to include("encrypted_password", "jti")
    end

    it "rejects a wrong password" do
      sign_in_as(email: "hr@acme.test", password: "wrong")
      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["Authorization"]).to be_nil
    end

    it "rejects an unknown email" do
      sign_in_as(email: "nobody@acme.test", password: "Secret123!")
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects missing credentials" do
      post "/api/v1/auth/sign_in", params: {}, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects a soft-deleted user" do
      user.soft_delete!
      sign_in_as(email: "hr@acme.test", password: "Secret123!")
      expect(response).to have_http_status(:unauthorized)
      expect(response.headers["Authorization"]).to be_nil
    end
  end

  describe "GET /api/v1/auth/me" do
    it "returns the signed-in user" do
      get "/api/v1/auth/me", headers: auth_headers_for(user)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["user"]["email"]).to eq("hr@acme.test")
    end

    it "rejects a request without a token" do
      get "/api/v1/auth/me", as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects a malformed token" do
      get "/api/v1/auth/me", headers: { "Authorization" => "Bearer not-a-jwt", "Accept" => "application/json" }
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects an expired token" do
      headers = auth_headers_for(user)
      travel_to(Devise::JWT.config.expiration_time.seconds.from_now + 1.minute) do
        get "/api/v1/auth/me", headers: headers
      end
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects a still-valid token once the user is soft-deleted" do
      headers = auth_headers_for(user)
      user.soft_delete!
      get "/api/v1/auth/me", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/auth/sign_out" do
    it "revokes the token so it can no longer be used" do
      headers = auth_headers_for(user)

      delete "/api/v1/auth/sign_out", headers: headers
      expect(response).to have_http_status(:no_content)

      get "/api/v1/auth/me", headers: headers
      expect(response).to have_http_status(:unauthorized)
    end

    it "rejects sign-out without a token" do
      delete "/api/v1/auth/sign_out", as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
