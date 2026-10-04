# The full employee record for the detail screen and create/update responses.
class EmployeeSerializer
  def self.call(employee)
    EmployeeLiteSerializer.call(employee).merge(
      first_name: employee.first_name,
      last_name: employee.last_name,
      joining_date: employee.joining_date,
      exit_date: employee.exit_date,
      country: Country.find(employee.country_code),
      current_salary: current_salary(employee.current_salary)
    )
  end

  def self.current_salary(salary)
    salary && salary.slice(:annual_salary, :currency, :effective_from)
                    .merge(salary_structure: salary.salary_structure.slice(:id, :name))
  end
end
