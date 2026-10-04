require "rails_helper"

RSpec.describe Employee do
  it "is valid with the factory defaults" do
    expect(build(:employee)).to be_valid
  end

  %i[employee_code first_name last_name email designation joining_date country_code].each do |field|
    it "requires #{field}" do
      employee = build(:employee, field => nil)
      expect(employee).not_to be_valid
      expect(employee.errors[field]).to be_present
    end
  end

  it "requires a department" do
    expect(build(:employee, department: nil)).not_to be_valid
  end

  it "rejects a soft-deleted department" do
    employee = build(:employee, department: create(:department, :deleted))
    expect(employee).not_to be_valid
    expect(employee.errors[:department]).to include("is deleted")
  end

  it "normalises email to lowercase without spaces" do
    expect(build(:employee, email: "  Asha@ACME.test ").email).to eq("asha@acme.test")
  end

  it "rejects a malformed email" do
    expect(build(:employee, email: "not-an-email")).not_to be_valid
  end

  it "rejects a duplicate email in any letter case" do
    create(:employee, email: "asha@acme.test")
    expect(build(:employee, email: "ASHA@acme.test")).not_to be_valid
  end

  it "rejects a duplicate employee code" do
    create(:employee, employee_code: "EMP000001")
    expect(build(:employee, employee_code: "EMP000001")).not_to be_valid
  end

  it "upcases the country code" do
    expect(build(:employee, country_code: "in").country_code).to eq("IN")
  end

  it "rejects an unsupported country" do
    employee = build(:employee, country_code: "ZZ")
    expect(employee).not_to be_valid
    expect(employee.errors[:country_code]).to include("is not supported")
  end

  it "rejects an unknown employment status" do
    expect(build(:employee, employment_status: "retired")).not_to be_valid
  end

  describe "exit date rules" do
    it "requires an exit date when terminated" do
      expect(build(:employee, employment_status: "terminated", exit_date: nil)).not_to be_valid
    end

    it "forbids an exit date unless terminated" do
      expect(build(:employee, employment_status: "active", exit_date: Date.new(2025, 1, 1))).not_to be_valid
    end

    it "rejects an exit date before the joining date" do
      employee = build(:employee, :terminated, joining_date: Date.new(2025, 1, 1), exit_date: Date.new(2024, 12, 31))
      expect(employee).not_to be_valid
      expect(employee.errors[:exit_date]).to include("can't be before the joining date")
    end

    it "accepts leaving on the joining date" do
      expect(build(:employee, :terminated, joining_date: Date.new(2025, 1, 1), exit_date: Date.new(2025, 1, 1))).to be_valid
    end
  end

  it "builds the full name" do
    expect(build(:employee, first_name: "Asha", last_name: "Verma").full_name).to eq("Asha Verma")
  end
end
