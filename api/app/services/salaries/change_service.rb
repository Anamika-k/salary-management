# Records a salary change for an employee in one transaction: closes the
# current salary the day before the new one starts, adds the new salary and
# audits both. History only moves forward; mistakes are fixed with a
# "correction" entry, never by editing the past.
module Salaries
  class ChangeService
    def initialize(employee:, params:, user:)
      @employee = employee
      @params = params.to_h.symbolize_keys
      @audit = Audit::Logger.new(user)
      @user = user
    end

    def call
      structure = SalaryStructure.kept.find(@params[:salary_structure_id])
      starts_on = @params[:effective_from].presence&.to_date

      EmployeeSalary.transaction do
        current = @employee.employee_salaries.kept.lock.find_by(effective_to: nil)
        check!(structure, starts_on, current) if starts_on
        close(current, starts_on) if current && starts_on
        create_salary(structure)
      end
    end

    private

    def check!(structure, starts_on, current)
      if starts_on < @employee.joining_date
        reject!("Salary can't start before the joining date (#{@employee.joining_date})")
      end
      if @employee.exit_date && starts_on >= @employee.exit_date
        reject!("Salary can't start on or after the exit date (#{@employee.exit_date})")
      end
      if current && starts_on <= current.effective_from
        reject!("A salary change must start after #{current.effective_from}, when the current salary began")
      end
      return if structure.country_code.nil? || structure.country_code == @employee.country_code

      reject!("#{structure.name} is for another country")
    end

    def reject!(message)
      raise InvalidChangeError, message
    end

    def close(current, starts_on)
      current.update!(effective_to: starts_on - 1)
      @audit.record(current, :updated)
    end

    def create_salary(structure)
      salary = @employee.employee_salaries.create!(
        @params.slice(:annual_salary, :effective_from, :change_type, :notes).merge(
          salary_structure: structure, created_by: @user,
          currency: Country.find(@employee.country_code)[:currency]
        )
      )
      @audit.record(salary, :created)
      salary
    end
  end
end
