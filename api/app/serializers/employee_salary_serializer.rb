# One period of an employee's pay history. Expects structure and creator preloaded.
class EmployeeSalarySerializer
  def self.call(salary)
    salary.slice(:id, :annual_salary, :currency, :effective_from, :effective_to, :change_type, :notes, :created_at)
          .symbolize_keys
          .merge(salary_structure: salary.salary_structure.slice(:id, :name),
                 created_by: salary.created_by.slice(:id, :name))
  end
end
