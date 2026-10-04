require "rails_helper"

RSpec.describe Salaries::ChangeService do
  let(:user) { create(:user) }
  let(:structure) { create(:salary_structure, country_code: "IN") }
  let(:employee) { create(:employee, country_code: "IN", joining_date: Date.new(2024, 1, 15)) }

  def change(effective_from:, annual_salary: 1_200_000, change_type: "joining", **extra)
    params = { annual_salary:, effective_from:, change_type:, salary_structure_id: structure.id, **extra }
    described_class.new(employee:, params:, user:).call
  end

  it "records the first salary with the currency of the employee's country" do
    salary = change(effective_from: "2024-01-15", notes: "Offer letter")
    expect(salary).to have_attributes(annual_salary: 1_200_000, currency: "INR", effective_to: nil,
                                      created_by: user, notes: "Offer letter")
  end

  it "closes the current salary the day before a raise starts" do
    first = change(effective_from: "2024-01-15")
    raise_ = change(effective_from: "2025-04-01", annual_salary: 1_320_000, change_type: "increment")

    expect(first.reload.effective_to).to eq(Date.new(2025, 3, 31))
    expect(raise_.effective_to).to be_nil
  end

  it "keeps today's salary until a future-dated raise starts" do
    travel_to(Date.new(2025, 6, 1)) do
      first = change(effective_from: "2024-01-15")
      change(effective_from: "2025-07-01", annual_salary: 1_400_000, change_type: "increment")
      expect(employee.reload.current_salary).to eq(first)
    end
  end

  describe "audit log" do
    it "records who created the salary and who closed the previous one" do
      first = change(effective_from: "2024-01-15")
      second = change(effective_from: "2025-04-01", change_type: "increment")

      logs = AuditLog.order(:id).map { |log| [ log.action, log.auditable, log.user ] }
      expect(logs).to eq([ [ "created", first, user ], [ "updated", first, user ], [ "created", second, user ] ])
      expect(AuditLog.order(:id).second.change_set).to eq("effective_to" => [ nil, "2025-03-31" ])
    end
  end

  describe "rejected changes" do
    def expect_rejected(message, **change_args)
      expect { change(**change_args) }.to raise_error(Salaries::InvalidChangeError, message)
    end

    it "rejects a start before the joining date" do
      expect_rejected(/joining date/, effective_from: "2024-01-14")
    end

    it "rejects a start on or after a terminated employee's exit date" do
      employee.update!(employment_status: "terminated", exit_date: Date.new(2025, 6, 30))
      expect_rejected(/exit date/, effective_from: "2025-06-30")
    end

    it "rejects a start on or before the current salary's start (changes only go forward)" do
      change(effective_from: "2024-06-01")
      expect_rejected(/after 2024-06-01/, effective_from: "2024-06-01")
      expect_rejected(/after 2024-06-01/, effective_from: "2024-03-01")
    end

    it "rejects a structure from another country or a deleted structure" do
      structure.update!(country_code: "US")
      expect_rejected(/country/, effective_from: "2024-01-15")

      structure.update!(country_code: nil, deleted_at: Time.current)
      expect { change(effective_from: "2024-01-15") }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "accepts a country-neutral structure" do
      structure.update!(country_code: nil)
      expect(change(effective_from: "2024-01-15")).to be_persisted
    end
  end

  it "saves nothing when the new salary is invalid" do
    first = change(effective_from: "2024-01-15")
    expect { change(effective_from: "2025-04-01", annual_salary: 0, change_type: "increment") }
      .to raise_error(ActiveRecord::RecordInvalid)

    expect(first.reload.effective_to).to be_nil
    expect([ EmployeeSalary.count, AuditLog.count ]).to eq([ 1, 1 ])
  end
end
