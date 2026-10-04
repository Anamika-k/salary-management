require "rails_helper"

RSpec.describe "GET /api/v1/employees/:id/audit_logs", type: :request do
  let(:user) { create(:user, name: "Priya HR") }
  let(:headers) { auth_headers_for(user) }
  let(:employee) { create(:employee, joining_date: Date.new(2024, 1, 15)) }
  let(:structure) { create(:salary_structure, country_code: "IN") }

  def change(effective_from, change_type)
    Salaries::ChangeService.new(employee:, user:, params: { annual_salary: 1_200_000, salary_structure_id: structure.id,
                                                            effective_from:, change_type: }).call
  end

  it "requires a signed-in user" do
    get "/api/v1/employees/#{employee.id}/audit_logs", as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it "returns the employee's salary audit trail, newest first, with who did it" do
    change("2024-01-15", "joining")
    change("2025-04-01", "increment")
    create(:audit_log) # another employee's salary
    get "/api/v1/employees/#{employee.id}/audit_logs", headers: headers

    data = response.parsed_body["data"]
    expect(data.pluck("action")).to eq(%w[created updated created])
    expect(data.first).to include("auditable_type" => "EmployeeSalary", "user" => { "id" => user.id, "name" => "Priya HR" })
    expect(data.first["change_set"]).to include("annual_salary" => [ nil, "1200000.0" ])
    expect(response.parsed_body["meta"]["total_count"]).to eq(3)
  end
end
