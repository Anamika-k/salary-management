require "rails_helper"

RSpec.describe Insights::PaidSalaries do
  it "includes today's salary of active and on-leave employees" do
    active = paid_employee("IN", 100_000)
    on_leave = paid_employee("IN", 200_000, status: "on_leave")
    expect(described_class.call.map(&:employee)).to contain_exactly(active, on_leave)
  end

  it "leaves out terminated and soft-deleted employees" do
    paid_employee("IN", 100_000, status: "terminated")
    paid_employee("IN", 100_000).soft_delete!
    expect(described_class.call).to be_empty
  end

  it "uses only the salary in effect today, not past, future or deleted ones" do
    employee = create(:employee)
    create(:employee_salary, employee:, annual_salary: 100_000, effective_from: Date.new(2024, 1, 15), effective_to: Date.new(2025, 1, 14))
    current = create(:employee_salary, employee:, annual_salary: 120_000, effective_from: Date.new(2025, 1, 15),
                                       effective_to: Date.current + 9)
    create(:employee_salary, employee:, annual_salary: 150_000, effective_from: Date.current + 10)
    create(:employee_salary, employee: create(:employee), deleted_at: Time.current)

    expect(described_class.call).to contain_exactly(current)
  end

  it "filters by country" do
    paid_employee("IN", 100_000)
    us = paid_employee("US", 90_000)
    expect(described_class.call(country: "US").map(&:employee)).to eq([ us ])
  end

  describe ".country!" do
    it "returns the country for a supported code, in any case" do
      expect(described_class.country!("in")).to eq(code: "IN", name: "India", currency: "INR")
    end

    it "raises a 400 error for an unsupported country" do
      expect { described_class.country!("XX") }.to raise_error(Insights::UnknownCountryError, "Unknown country: XX")
      expect(Insights::UnknownCountryError.new.status).to eq(:bad_request)
    end
  end
end
