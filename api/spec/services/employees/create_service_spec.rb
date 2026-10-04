require "rails_helper"

RSpec.describe Employees::CreateService do
  let(:department) { create(:department) }
  let(:attributes) do
    { first_name: "Asha", last_name: "Verma", email: "asha@acme.test", country_code: "IN",
      department_id: department.id, designation: "Engineer", joining_date: "2025-04-01" }
  end

  it "creates the employee with the first code when none exist" do
    employee = described_class.new(attributes).call
    expect(employee).to be_persisted
    expect(employee.employee_code).to eq("EMP000001")
  end

  it "continues from the highest existing code, including soft-deleted employees" do
    create(:employee, employee_code: "EMP000041")
    create(:employee, :deleted, employee_code: "EMP000042")
    expect(described_class.new(attributes).call.employee_code).to eq("EMP000043")
  end

  it "ignores any employee code passed in" do
    expect(described_class.new(attributes.merge(employee_code: "HACK")).call.employee_code).to eq("EMP000001")
  end

  it "raises a validation error for invalid attributes and saves nothing" do
    expect { described_class.new(attributes.merge(email: "")).call }.to raise_error(ActiveRecord::RecordInvalid)
    expect(Employee.count).to eq(0)
  end
end
