# The latest raises, promotions and corrections (joining salaries are not
# changes), newest first, each with the previous salary and the % change.
# Future-dated changes and deleted employees are left out.
module Insights
  class RecentChanges
    DEFAULT_LIMIT = 10
    MAX_LIMIT = 50

    def self.changes
      EmployeeSalary.kept.where.not(change_type: "joining").where(effective_from: ..Date.current)
                    .joins(:employee).merge(Employee.kept)
    end

    def initialize(country: nil, limit: nil)
      @country = PaidSalaries.country!(country)[:code] if country.present?
      @limit = (limit.presence || DEFAULT_LIMIT).to_i.clamp(1, MAX_LIMIT)
    end

    def call
      salaries = self.class.changes.includes(employee: :department).order(effective_from: :desc, id: :desc).limit(@limit)
      salaries = salaries.merge(Employee.in_country(@country)) if @country
      salaries = salaries.to_a
      previous = previous_salaries(salaries)
      salaries.map { |salary| row(salary, previous[[ salary.employee_id, salary.effective_from - 1 ]]) }
    end

    private

    # The salary each change replaced ended the day before it started; one query for all.
    def previous_salaries(salaries)
      EmployeeSalary.kept.where(employee_id: salaries.map(&:employee_id), effective_to: salaries.map { |s| s.effective_from - 1 })
                    .index_by { |salary| [ salary.employee_id, salary.effective_to ] }
    end

    def row(salary, previous)
      employee = salary.employee
      {
        id: salary.id, change_type: salary.change_type, effective_from: salary.effective_from,
        annual_salary: salary.annual_salary, currency: salary.currency,
        previous_salary: previous&.annual_salary, change_percent: previous && percent(previous.annual_salary, salary.annual_salary),
        employee: { id: employee.id, full_name: employee.full_name, employee_code: employee.employee_code,
                    designation: employee.designation, department: employee.department.name }
      }
    end

    def percent(before, after)
      ((after - before) / before * 100).round(1)
    end
  end
end
