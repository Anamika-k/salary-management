require "rails_helper"

RSpec.describe Insights::RecentChanges do
  let(:employee) { create(:employee, first_name: "Asha", last_name: "Verma", joining_date: Date.new(2024, 1, 15)) }

  def raise_salary(employee, from:, amount:, type: "increment")
    previous = employee.employee_salaries.find_by(effective_to: nil)
    previous&.update!(effective_to: from - 1)
    create(:employee_salary, employee:, annual_salary: amount, effective_from: from, change_type: type)
  end

  before do
    create(:employee_salary, employee:, annual_salary: 1_000_000, effective_from: employee.joining_date)
    raise_salary(employee, from: Date.new(2025, 1, 15), amount: 1_100_000)
    raise_salary(employee, from: Date.new(2026, 1, 15), amount: 1_320_000, type: "promotion")
  end

  it "lists raises and promotions newest first with the change from the previous salary" do
    result = described_class.new.call
    expect(result.map { |change| [ change[:change_type], change[:annual_salary], change[:previous_salary], change[:change_percent] ] })
      .to eq([ [ "promotion", 1_320_000, 1_100_000, 20.0 ], [ "increment", 1_100_000, 1_000_000, 10.0 ] ])
    expect(result.first[:employee]).to include(id: employee.id, full_name: "Asha Verma")
  end

  it "leaves out joining salaries, future-dated changes and deleted employees" do
    raise_salary(employee, from: Date.current + 30, amount: 1_500_000)
    paid_employee("IN", 900_000).soft_delete!
    expect(described_class.new.call.size).to eq(2)
  end

  it "filters by country and keeps the limit between 1 and 50" do
    expect(described_class.new(country: "US").call).to be_empty
    expect(described_class.new(limit: "1").call.size).to eq(1)
    expect(described_class.new(limit: "0").call.size).to eq(1)
    expect(described_class::MAX_LIMIT).to eq(50)
  end

  it "loads previous salaries without one query per change (no N+1)" do
    other = create(:employee, joining_date: Date.new(2024, 1, 15))
    create(:employee_salary, employee: other, effective_from: other.joining_date)
    one = count_queries { described_class.new.call }
    raise_salary(other, from: Date.new(2025, 6, 1), amount: 1_300_000)
    expect(count_queries { described_class.new.call }).to eq(one)
  end
end
