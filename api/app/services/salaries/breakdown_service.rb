# The monthly breakdown of the salary an employee had on a given date, using
# that salary's structure. Raises RecordNotFound when no salary applied then.
module Salaries
  class BreakdownService
    def initialize(employee:, on:)
      @employee = employee
      @on = on
    end

    def call
      salary = @employee.employee_salaries.kept.as_of(@on)
                        .includes(salary_structure: { rules: %i[salary_component base_component] }).first!
      Calculator.new(annual_salary: salary.annual_salary, structure: salary.salary_structure).call
                .merge(currency: salary.currency, effective_from: salary.effective_from, effective_to: salary.effective_to)
    end
  end
end
