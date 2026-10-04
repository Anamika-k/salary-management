require "rails_helper"

RSpec.describe Department do
  it "is valid with a name" do
    expect(build(:department, name: "Engineering")).to be_valid
  end

  it "requires a name" do
    department = build(:department, name: " ")
    expect(department).not_to be_valid
    expect(department.errors[:name]).to include("can't be blank")
  end

  it "strips surrounding spaces from the name" do
    expect(build(:department, name: "  Finance  ").name).to eq("Finance")
  end

  it "rejects a duplicate name in any letter case" do
    create(:department, name: "Engineering")
    expect(build(:department, name: "ENGINEERING")).not_to be_valid
  end

  it "has employees" do
    department = create(:department)
    employee = create(:employee, department:)
    expect(department.employees).to contain_exactly(employee)
  end
end
