# Builds an employee with one open salary in their country's currency, so
# insights specs can describe a small, exact dataset in one line each, e.g.
#   paid_employee("IN", 1_200_000, designation: "Engineer")
module InsightsHelpers
  def paid_employee(country, amount, status: "active", **employee_attributes)
    exit_date = Date.current - 1 if status == "terminated"
    employee = create(:employee, country_code: country, employment_status: status, exit_date:, **employee_attributes)
    create(:employee_salary, employee:, annual_salary: amount, currency: Country.find(country)[:currency],
                             effective_from: employee.joining_date)
    employee
  end
end

RSpec.configure do |config|
  config.include InsightsHelpers
end
