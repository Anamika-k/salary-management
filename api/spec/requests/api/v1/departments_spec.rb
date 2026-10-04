require "rails_helper"

RSpec.describe "Departments", type: :request do
  let(:headers) { auth_headers_for(create(:user)) }

  it "requires a signed-in user" do
    get "/api/v1/departments", as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  describe "GET /api/v1/departments" do
    it "lists live departments by name, paginated" do
      create(:department, name: "Finance")
      create(:department, name: "Engineering")
      create(:department, :deleted, name: "Old")
      get "/api/v1/departments", headers: headers

      expect(response.parsed_body["data"].pluck("name")).to eq(%w[Engineering Finance])
      expect(response.parsed_body["meta"]["total_count"]).to eq(2)
    end
  end

  describe "POST /api/v1/departments" do
    it "creates a department" do
      post "/api/v1/departments", params: { department: { name: "Legal" } }, headers: headers, as: :json
      expect(response).to have_http_status(:created)
      expect(response.parsed_body["data"]).to include("name" => "Legal")
    end

    it "returns 422 for a duplicate name" do
      create(:department, name: "Legal")
      post "/api/v1/departments", params: { department: { name: "legal" } }, headers: headers, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "PATCH /api/v1/departments/:id" do
    it "renames a department" do
      department = create(:department, name: "Legal")
      patch "/api/v1/departments/#{department.id}", params: { department: { name: "Legal & Compliance" } },
                                                    headers: headers, as: :json
      expect(response).to have_http_status(:ok)
      expect(department.reload.name).to eq("Legal & Compliance")
    end

    it "returns 404 for a soft-deleted department" do
      department = create(:department, :deleted)
      patch "/api/v1/departments/#{department.id}", params: { department: { name: "X" } }, headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/departments/:id" do
    it "soft deletes an empty department" do
      department = create(:department)
      delete "/api/v1/departments/#{department.id}", headers: headers
      expect(response).to have_http_status(:no_content)
      expect(department.reload).to be_deleted
    end

    it "returns 409 while employees belong to it" do
      department = create(:department)
      create(:employee, department:)
      delete "/api/v1/departments/#{department.id}", headers: headers

      expect(response).to have_http_status(:conflict)
      expect(response.parsed_body).to include("code" => "in_use_error", "details" => { "employee_count" => 1 })
    end
  end
end
