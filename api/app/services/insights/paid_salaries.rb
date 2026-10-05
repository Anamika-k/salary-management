# The one definition of "who we pay today" for every pay figure: the salary in
# effect today of each live employee who is active or on leave. Terminated and
# soft-deleted employees, and past or future salaries, never count.
module Insights
  module PaidSalaries
    PAID_STATUSES = %w[active on_leave].freeze

    def self.call(country: nil)
      salaries = EmployeeSalary.kept.as_of(Date.current).joins(:employee)
                               .merge(Employee.kept.with_status(PAID_STATUSES))
      country ? salaries.merge(Employee.in_country(country)) : salaries
    end

    # Pay is only comparable within one currency, so most reports need a country.
    def self.country!(code)
      Country.find(code.to_s.upcase) || raise(UnknownCountryError, "Unknown country: #{code}")
    end
  end
end
