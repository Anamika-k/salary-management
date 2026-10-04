# Raised when HR tries to delete a department that still has employees.
# They must be moved to another department first.
module Departments
  class InUseError < ApplicationError
    def initialize(employee_count)
      super("Department still has #{employee_count} #{'employee'.pluralize(employee_count)}; move them first",
            details: { employee_count: })
    end

    def status
      :conflict
    end
  end
end
