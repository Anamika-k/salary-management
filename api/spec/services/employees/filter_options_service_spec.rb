require "rails_helper"

RSpec.describe Employees::FilterOptionsService do
  subject(:options) { described_class.new.call }

  it "lists live departments by name" do
    finance = create(:department, name: "Finance")
    engineering = create(:department, name: "Engineering")
    create(:department, :deleted, name: "Old")

    expect(options[:departments]).to eq([ { id: engineering.id, name: "Engineering" }, { id: finance.id, name: "Finance" } ])
  end

  it "lists every supported country" do
    expect(options[:countries]).to eq(Country.all)
  end

  it "lists designations in use by live employees, once each, sorted" do
    create(:employee, designation: "Engineer")
    create(:employee, designation: "Accountant")
    create(:employee, designation: "Engineer")
    create(:employee, :deleted, designation: "Ghost")

    expect(options[:designations]).to eq(%w[Accountant Engineer])
  end

  it "lists the employment statuses" do
    expect(options[:employment_statuses]).to eq(%w[active on_leave terminated])
  end
end
