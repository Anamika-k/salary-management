require "rails_helper"

RSpec.describe Insights::Summary do
  before { travel_to Date.new(2026, 10, 4) }

  it "counts headcount by status, joiners and leavers this year, and recent salary changes" do
    paid_employee("IN", 1_000_000, joining_date: Date.new(2026, 3, 1))
    paid_employee("IN", 1_000_000, status: "on_leave")
    paid_employee("US", 90_000, status: "terminated") # exit date: yesterday
    create(:employee, employment_status: "active") # paid group, but no salary yet
    paid_employee("IN", 1_000_000).soft_delete!
    raised = paid_employee("GB", 60_000)
    raised.employee_salaries.first.update!(effective_to: Date.new(2026, 9, 19))
    create(:employee_salary, employee: raised, annual_salary: 65_000, currency: "GBP",
                             effective_from: Date.new(2026, 9, 20), change_type: "increment")

    expect(described_class.new.call).to eq(
      headcount: { total: 5, active: 3, on_leave: 1, terminated: 1 },
      joiners_this_year: 1,
      leavers_this_year: 1,
      salary_changes_last_30_days: 1,
      paid_without_salary: 1,
      countries: 3
    )
  end
end
