# The full employee record for the detail screen and create/update responses.
class EmployeeSerializer
  def self.call(employee)
    EmployeeLiteSerializer.call(employee).merge(
      first_name: employee.first_name,
      last_name: employee.last_name,
      joining_date: employee.joining_date,
      exit_date: employee.exit_date,
      country: Country.find(employee.country_code)
    )
  end
end
