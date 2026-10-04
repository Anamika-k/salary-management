require "rails_helper"

RSpec.describe "GET /api/v1/filters", type: :request do
  it "requires a signed-in user" do
    get "/api/v1/filters", as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it "returns every dropdown option in one payload" do
    employee = create(:employee, designation: "Engineer")
    get "/api/v1/filters", headers: auth_headers_for(create(:user))

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["data"]).to include(
      "departments" => [ { "id" => employee.department_id, "name" => employee.department.name } ],
      "designations" => [ "Engineer" ],
      "employment_statuses" => %w[active on_leave terminated]
    )
    expect(response.parsed_body["data"]["countries"]).to include("code" => "IN", "name" => "India", "currency" => "INR")
  end
end
