require "rails_helper"

RSpec.describe "Employee salaries", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers_for(user) }
  let(:structure) { create(:salary_structure, name: "India Standard", country_code: "IN") }
  let(:employee) { create(:employee, joining_date: Date.new(2024, 1, 15)) }
  let(:base_path) { "/api/v1/employees/#{employee.id}/salaries" }

  before do
    add_rule(structure, "BASIC", :percentage_of_gross, 50)
    add_rule(structure, "SPECIAL", :remainder)
    add_rule(structure, "PF", :percentage_of_component, 12, type: :deduction, base: "BASIC")
  end

  def salary(from, to = nil, amount: 1_200_000)
    create(:employee_salary, employee:, salary_structure: structure, annual_salary: amount,
                             effective_from: Date.parse(from), effective_to: to && Date.parse(to))
  end

  it "requires a signed-in user" do
    get base_path, as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  describe "GET /employees/:id/salaries" do
    it "returns the pay history, newest first" do
      salary("2024-01-15", "2025-03-31")
      salary("2025-04-01", amount: 1_320_000)
      get base_path, headers: headers

      data = response.parsed_body["data"]
      expect(data.pluck("effective_from")).to eq(%w[2025-04-01 2024-01-15])
      expect(data.first).to include("annual_salary" => "1320000.0", "currency" => "INR", "effective_to" => nil,
                                    "change_type" => "joining", "salary_structure" => include("name" => "India Standard"))
    end

    it "returns 404 for a soft-deleted employee" do
      employee.soft_delete!
      get base_path, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /employees/:id/salaries" do
    let(:params) do
      { salary: { annual_salary: "1200000", salary_structure_id: structure.id, effective_from: "2024-01-15",
                  change_type: "joining", notes: "Offer letter" } }
    end

    it "records a salary change made by the signed-in user" do
      post base_path, params:, headers:, as: :json
      expect(response).to have_http_status(:created)
      expect(response.parsed_body["data"]).to include("annual_salary" => "1200000.0", "created_by" => include("id" => user.id))
    end

    it "returns 422 for a change that breaks the history rules" do
      post base_path, params: { salary: params[:salary].merge(effective_from: "2023-01-01") }, headers:, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["code"]).to eq("invalid_change_error")
    end

    it "returns 422 with field errors for an invalid amount" do
      post base_path, params: { salary: params[:salary].merge(annual_salary: "-5") }, headers:, as: :json
      expect(response.parsed_body["details"]).to have_key("annual_salary")
    end
  end

  describe "GET /employees/:id/salaries/breakdown" do
    before do
      salary("2024-01-15", "2025-03-31")
      salary("2025-04-01", amount: 2_400_000)
    end

    it "breaks down the salary in effect on the given date" do
      get "#{base_path}/breakdown", params: { on: "2024-06-01" }, headers: headers
      expect(response.parsed_body["data"]).to include("monthly_gross" => "100000.0", "currency" => "INR",
                                                      "effective_from" => "2024-01-15")
    end

    it "defaults to today" do
      get "#{base_path}/breakdown", headers: headers
      expect(response.parsed_body["data"]["monthly_gross"]).to eq("200000.0")
    end

    it "returns 404 when there was no salary on that date and 400 for a bad date" do
      get "#{base_path}/breakdown", params: { on: "2023-01-01" }, headers: headers
      expect(response).to have_http_status(:not_found)

      get "#{base_path}/breakdown", params: { on: "not-a-date" }, headers: headers
      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["code"]).to eq("invalid_date")
    end
  end
end
