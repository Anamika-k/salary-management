require "rails_helper"

RSpec.describe "GET /api/v1/employees", type: :request do
  let(:headers) { auth_headers_for(create(:user)) }
  let(:department) { create(:department, name: "Engineering") }

  def list(params = {})
    get "/api/v1/employees", params:, headers:
  end

  it "requires a signed-in user" do
    get "/api/v1/employees", as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it "returns the lite fields only" do
    employee = create(:employee, department:)
    list

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["data"]).to eq([ {
      "id" => employee.id, "employee_code" => employee.employee_code, "full_name" => "Asha Verma",
      "email" => employee.email, "designation" => "Software Engineer", "country_code" => "IN",
      "employment_status" => "active", "department" => { "id" => department.id, "name" => "Engineering" },
      "current_salary" => nil
    } ])
  end

  it "includes today's salary" do
    employee = create(:employee, department:)
    create(:employee_salary, employee:, annual_salary: 1_500_000, currency: "INR", effective_from: Date.current - 1)
    list
    expect(response.parsed_body["data"].first["current_salary"]).to eq("annual_salary" => "1500000.0", "currency" => "INR")
  end

  it "applies search and filters" do
    create(:employee, first_name: "Asha", country_code: "IN")
    create(:employee, first_name: "John", country_code: "US")
    list(q: "john", country_code: "US")

    expect(response.parsed_body["data"].pluck("full_name")).to eq([ "John Verma" ])
  end

  describe "pagination" do
    before { create_list(:employee, 3, department:) }

    it "returns pagination meta" do
      list(page: 2, per_page: 2)
      expect(response.parsed_body["data"].size).to eq(1)
      expect(response.parsed_body["meta"]).to eq(
        "current_page" => 2, "total_pages" => 2, "total_count" => 3, "per_page" => 2
      )
    end

    it "returns an empty page past the end" do
      list(page: 9, per_page: 2)
      expect(response.parsed_body["data"]).to be_empty
    end

    it "defaults to 25 per page and caps per_page at 100" do
      list
      expect(response.parsed_body["meta"]["per_page"]).to eq(25)
      list(per_page: 5000)
      expect(response.parsed_body["meta"]["per_page"]).to eq(100)
    end

    it "falls back to defaults for invalid values" do
      list(page: "abc", per_page: "-3")
      expect(response.parsed_body["meta"]).to include("current_page" => 1, "per_page" => 25)
    end
  end

  it "runs the same number of queries however many employees are listed (no N+1)" do
    create(:employee_salary, employee: create(:employee, department: create(:department)))
    headers
    one = count_queries { list }

    create_list(:employee, 3).each { |employee| create(:employee_salary, employee:) } # each in its own department
    expect(count_queries { list }).to eq(one)
  end
end
