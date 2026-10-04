# Only the columns the employee list shows. Expects the department to be
# preloaded (Employees::SearchService includes it) so there is no N+1.
class EmployeeLiteSerializer
  def self.call(employee)
    {
      id: employee.id,
      employee_code: employee.employee_code,
      full_name: employee.full_name,
      email: employee.email,
      designation: employee.designation,
      country_code: employee.country_code,
      employment_status: employee.employment_status,
      department: DepartmentSerializer.call(employee.department)
    }
  end
end
