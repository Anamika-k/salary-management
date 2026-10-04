require "rails_helper"

RSpec.describe "Employee create, show, update and delete", type: :request do
  let(:headers) { auth_headers_for(create(:user)) }
  let(:department) { create(:department) }
  let(:employee) { create(:employee, department:) }
  let(:valid_attributes) do
    { first_name: "Asha", last_name: "Verma", email: "asha@acme.test", country_code: "IN",
      department_id: department.id, designation: "Engineer", joining_date: "2025-04-01" }
  end

  describe "GET /api/v1/employees/:id" do
    it "returns the full record" do
      get "/api/v1/employees/#{employee.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"]).to include(
        "id" => employee.id, "first_name" => "Asha", "last_name" => "Verma", "joining_date" => "2024-01-15",
        "exit_date" => nil, "country" => { "code" => "IN", "name" => "India", "currency" => "INR" }
      )
    end

    it "returns 404 for a missing or soft-deleted employee" do
      get "/api/v1/employees/0", headers: headers
      expect(response).to have_http_status(:not_found)
      expect(response.parsed_body["code"]).to eq("not_found")

      get "/api/v1/employees/#{create(:employee, :deleted).id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/employees" do
    it "creates an employee with a generated code" do
      post "/api/v1/employees", params: { employee: valid_attributes }, headers: headers, as: :json
      expect(response).to have_http_status(:created)
      expect(response.parsed_body["data"]).to include("employee_code" => "EMP000001", "employment_status" => "active")
    end

    it "returns field errors for invalid input" do
      post "/api/v1/employees", params: { employee: valid_attributes.merge(email: "bad", country_code: "ZZ") },
                                headers: headers, as: :json
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body["code"]).to eq("record_invalid")
      expect(response.parsed_body["details"].keys).to include("email", "country_code")
    end

    it "returns 422 for an unknown department" do
      post "/api/v1/employees", params: { employee: valid_attributes.merge(department_id: 0) },
                                headers: headers, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns 400 when no employee attributes are sent" do
      post "/api/v1/employees", params: { unknown: "x" }, headers: headers, as: :json
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe "PATCH /api/v1/employees/:id" do
    it "updates the employee" do
      patch "/api/v1/employees/#{employee.id}", params: { employee: { designation: "Lead" } }, headers: headers, as: :json
      expect(response).to have_http_status(:ok)
      expect(employee.reload.designation).to eq("Lead")
    end

    it "never changes the employee code" do
      patch "/api/v1/employees/#{employee.id}", params: { employee: { employee_code: "X1", designation: "Lead" } },
                                                headers: headers, as: :json
      expect(employee.reload.employee_code).not_to eq("X1")
    end

    it "terminates with an exit date, and rejects terminating without one" do
      patch "/api/v1/employees/#{employee.id}", params: { employee: { employment_status: "terminated" } },
                                                headers: headers, as: :json
      expect(response).to have_http_status(:unprocessable_content)

      patch "/api/v1/employees/#{employee.id}",
            params: { employee: { employment_status: "terminated", exit_date: "2025-06-30" } }, headers: headers, as: :json
      expect(response).to have_http_status(:ok)
    end
  end

  describe "DELETE /api/v1/employees/:id" do
    it "soft deletes, then the employee is gone from the API" do
      delete "/api/v1/employees/#{employee.id}", headers: headers
      expect(response).to have_http_status(:no_content)
      expect(employee.reload).to be_deleted

      delete "/api/v1/employees/#{employee.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
