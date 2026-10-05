require "rails_helper"

RSpec.describe "Insights API", type: :request do
  let(:headers) { auth_headers_for(create(:user)) }

  before do
    paid_employee("IN", 1_000_000, designation: "Engineer")
    paid_employee("IN", 2_000_000, designation: "Engineer")
    paid_employee("US", 90_000)
  end

  it "requires a signed-in user" do
    get "/api/v1/insights/summary", as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it "GET /insights/summary" do
    get "/api/v1/insights/summary", headers: headers
    expect(response.parsed_body["data"]["headcount"]).to include("total" => 3, "active" => 3)
  end

  it "GET /insights/by_country returns amounts as decimal strings per currency" do
    get "/api/v1/insights/by_country", headers: headers
    india = response.parsed_body["data"].first
    expect(india).to include("country_code" => "IN", "currency" => "INR", "headcount" => 2,
                             "total_cost" => "3000000.0", "median" => "1500000.0")
  end

  it "GET /insights/by_department and /by_designation need a country" do
    get "/api/v1/insights/by_department", headers: headers
    expect(response).to have_http_status(:bad_request)
    expect(response.parsed_body["code"]).to eq("parameter_missing")

    get "/api/v1/insights/by_designation", params: { country: "IN" }, headers: headers
    expect(response.parsed_body["data"]["groups"].first).to include("designation" => "Engineer", "headcount" => 2)
  end

  it "GET /insights/by_department rejects an unknown country with 400" do
    get "/api/v1/insights/by_department", params: { country: "XX" }, headers: headers
    expect(response).to have_http_status(:bad_request)
    expect(response.parsed_body["code"]).to eq("unknown_country_error")
  end

  it "GET /insights/distribution" do
    get "/api/v1/insights/distribution", params: { country: "IN" }, headers: headers
    expect(response.parsed_body["data"]).to include("currency" => "INR", "headcount" => 2)
  end

  it "GET /insights/recent_changes" do
    get "/api/v1/insights/recent_changes", params: { limit: 5 }, headers: headers
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["data"]).to eq([])
  end
end
