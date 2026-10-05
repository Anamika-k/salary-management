# Headline numbers for the dashboard: headcount by status, joiners and leavers
# this year, salary changes in the last 30 days, and paid employees still
# missing a salary (a data gap HR should fix).
module Insights
  class Summary
    def call
      by_status = employees.group(:employment_status).count
      {
        headcount: { total: by_status.values.sum, active: by_status.fetch("active", 0),
                     on_leave: by_status.fetch("on_leave", 0), terminated: by_status.fetch("terminated", 0) },
        joiners_this_year: employees.where(joining_date: this_year).count,
        leavers_this_year: employees.where(exit_date: this_year).count,
        salary_changes_last_30_days: RecentChanges.changes.where(effective_from: (Date.current - 30)..Date.current).count,
        paid_without_salary: by_status.values_at(*PaidSalaries::PAID_STATUSES).compact.sum - PaidSalaries.call.count,
        countries: employees.distinct.count(:country_code)
      }
    end

    private

    def employees
      Employee.kept
    end

    def this_year
      Date.current.beginning_of_year..Date.current
    end
  end
end
