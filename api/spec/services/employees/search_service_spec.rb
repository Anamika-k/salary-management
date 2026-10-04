require "rails_helper"

RSpec.describe Employees::SearchService do
  let(:engineering) { create(:department, name: "Engineering") }
  let(:finance) { create(:department, name: "Finance") }
  let!(:asha) do
    create(:employee, employee_code: "EMP000001", first_name: "Asha", last_name: "Verma", email: "asha@acme.test",
                      department: engineering, country_code: "IN", designation: "Engineer", joining_date: Date.new(2023, 1, 1))
  end
  let!(:john) do
    create(:employee, employee_code: "EMP000002", first_name: "John", last_name: "Smith", email: "john@acme.test",
                      department: finance, country_code: "US", designation: "Accountant", joining_date: Date.new(2024, 1, 1))
  end
  let!(:maria) do
    create(:employee, :terminated, employee_code: "EMP000003", first_name: "Maria", last_name: "Lopez",
                                   email: "maria@acme.test", department: engineering, country_code: "US",
                                   designation: "Engineer", joining_date: Date.new(2022, 1, 1))
  end

  def search(params = {})
    described_class.new(ActionController::Parameters.new(params)).call.to_a
  end

  it "returns every live employee ordered by employee code by default" do
    expect(search).to eq([ asha, john, maria ])
  end

  it "never returns soft-deleted employees" do
    john.soft_delete!
    expect(search).to eq([ asha, maria ])
  end

  describe "search" do
    it "matches part of a first name, case-insensitively" do
      expect(search(q: "ash")).to eq([ asha ])
    end

    it "matches a last name, email or employee code" do
      expect(search(q: "smith")).to eq([ john ])
      expect(search(q: "maria@")).to eq([ maria ])
      expect(search(q: "EMP000002")).to eq([ john ])
    end

    it "matches a full name across first and last name" do
      expect(search(q: "asha verma")).to eq([ asha ])
    end

    it "returns everyone for a blank search" do
      expect(search(q: "  ")).to eq([ asha, john, maria ])
    end

    it "treats SQL wildcards as plain text" do
      expect(search(q: "%")).to be_empty
    end
  end

  describe "filters" do
    it "filters by department, country, status and designation" do
      expect(search(department_id: finance.id)).to eq([ john ])
      expect(search(country_code: "us")).to eq([ john, maria ])
      expect(search(employment_status: "terminated")).to eq([ maria ])
      expect(search(designation: "Engineer")).to eq([ asha, maria ])
    end

    it "combines filters" do
      expect(search(country_code: "US", department_id: engineering.id)).to eq([ maria ])
    end

    it "returns nothing for an unknown value instead of failing" do
      expect(search(employment_status: "retired")).to be_empty
      expect(search(department_id: "abc")).to be_empty
    end
  end

  describe "sorting" do
    it "sorts by an allowed column in either direction" do
      expect(search(sort: "joining_date", direction: "desc")).to eq([ john, asha, maria ])
      expect(search(sort: "first_name", direction: "asc")).to eq([ asha, john, maria ])
    end

    it "falls back to the default order for a column that isn't allowed" do
      expect(search(sort: "email; DROP TABLE employees", direction: "sideways")).to eq([ asha, john, maria ])
    end
  end
end
