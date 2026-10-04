require "rails_helper"

RSpec.describe EmployeeSalary do
  it "is valid with the factory defaults" do
    expect(build(:employee_salary)).to be_valid
  end

  %i[annual_salary currency effective_from].each do |field|
    it "requires #{field}" do
      expect(build(:employee_salary, field => nil)).not_to be_valid
    end
  end

  it "requires a positive annual salary" do
    expect(build(:employee_salary, annual_salary: 0)).not_to be_valid
  end

  it "requires a 3-letter currency" do
    expect(build(:employee_salary, currency: "RUPEE")).not_to be_valid
  end

  it "rejects an unknown change type" do
    expect(build(:employee_salary, change_type: "bonus")).not_to be_valid
  end

  it "rejects an end date before the start date" do
    salary = build(:employee_salary, effective_from: Date.new(2025, 1, 1), effective_to: Date.new(2024, 12, 31))
    expect(salary).not_to be_valid
  end

  describe ".as_of" do
    let(:employee) { create(:employee) }
    let!(:old) do
      create(:employee_salary, employee:, effective_from: Date.new(2024, 1, 1), effective_to: Date.new(2024, 12, 31))
    end
    let!(:current) { create(:employee_salary, employee:, effective_from: Date.new(2025, 1, 1)) }

    it "finds the salary in effect on a date, including both boundary days" do
      expect(described_class.as_of(Date.new(2024, 1, 1))).to eq([ old ])
      expect(described_class.as_of(Date.new(2024, 12, 31))).to eq([ old ])
      expect(described_class.as_of(Date.new(2025, 1, 1))).to eq([ current ])
      expect(described_class.as_of(Date.new(2030, 1, 1))).to eq([ current ])
    end

    it "finds nothing before the first salary" do
      expect(described_class.as_of(Date.new(2023, 12, 31))).to be_empty
    end
  end

  it "gives the employee a current salary that ignores future and deleted rows" do
    employee = create(:employee)
    today = create(:employee_salary, employee:, effective_from: Date.current - 30, effective_to: Date.current + 9)
    create(:employee_salary, employee:, effective_from: Date.current + 10)
    expect(employee.reload.current_salary).to eq(today)

    today.soft_delete!
    expect(employee.reload.current_salary).to be_nil
  end
end
