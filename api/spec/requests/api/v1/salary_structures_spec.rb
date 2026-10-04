require "rails_helper"

RSpec.describe "Salary structures and components", type: :request do
  let(:headers) { auth_headers_for(create(:user)) }
  let(:structure) { create(:salary_structure, code: "IN_STD", name: "India Standard", country_code: "IN") }

  before do
    add_rule(structure, "BASIC", :percentage_of_gross, 50)
    add_rule(structure, "SPECIAL", :remainder)
    add_rule(structure, "PF", :percentage_of_component, 12, type: :deduction, base: "BASIC")
  end

  it "requires a signed-in user" do
    %w[/api/v1/salary_components /api/v1/salary_structures].each do |path|
      get path, as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  it "lists live salary components" do
    create(:salary_component, code: "OLD", deleted_at: Time.current)
    get "/api/v1/salary_components", headers: headers
    expect(response.parsed_body["data"].pluck("code")).to contain_exactly("BASIC", "SPECIAL", "PF")
    expect(response.parsed_body["data"].first.keys).to contain_exactly("id", "code", "name", "component_type", "description")
  end

  it "lists live structures without their rules" do
    create(:salary_structure, deleted_at: Time.current)
    get "/api/v1/salary_structures", headers: headers
    expect(response.parsed_body["data"]).to eq([ { "id" => structure.id, "code" => "IN_STD", "name" => "India Standard",
                                                   "country_code" => "IN", "currency" => "INR", "description" => nil } ])
    expect(response.parsed_body["meta"]["total_count"]).to eq(1)
  end

  describe "GET /api/v1/salary_structures/:id" do
    it "returns the structure with its rules in order" do
      get "/api/v1/salary_structures/#{structure.id}", headers: headers
      rules = response.parsed_body["data"]["components"]

      expect(rules.map { |rule| rule["component"]["code"] }).to eq(%w[BASIC SPECIAL PF])
      expect(rules.last).to include("calculation_method" => "percentage_of_component", "value" => "12.0",
                                    "base_component" => include("code" => "BASIC"))
    end

    it "returns 404 for a soft-deleted structure" do
      structure.soft_delete!
      get "/api/v1/salary_structures/#{structure.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it "runs the same number of queries however many rules there are (no N+1)" do
      headers
      before = count_queries { get "/api/v1/salary_structures/#{structure.id}", headers: headers }
      add_rule(structure, "TAX", :percentage_of_gross, 10, type: :deduction)
      add_rule(structure, "INS", :fixed, 100, type: :deduction)
      expect(count_queries { get "/api/v1/salary_structures/#{structure.id}", headers: headers }).to eq(before)
    end
  end

  describe "GET /api/v1/salary_structures/:id/preview" do
    it "returns the monthly breakdown for an annual salary" do
      get "/api/v1/salary_structures/#{structure.id}/preview", params: { annual_salary: "1200000" }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"]).to include("monthly_gross" => "100000.0", "total_deductions" => "6000.0",
                                                      "net_pay" => "94000.0", "currency" => "INR")
    end

    it "returns 422 for an invalid amount and 400 when it's missing" do
      get "/api/v1/salary_structures/#{structure.id}/preview", params: { annual_salary: "-1" }, headers: headers
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["code"]).to eq("breakdown_error")

      get "/api/v1/salary_structures/#{structure.id}/preview", headers: headers
      expect(response).to have_http_status(:bad_request)
    end
  end
end
