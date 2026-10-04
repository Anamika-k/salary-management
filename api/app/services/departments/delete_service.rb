# Soft deletes a department, refusing while live employees still belong to it
# (terminated ones count: they stay in history and reports).
module Departments
  class DeleteService
    def initialize(department)
      @department = department
    end

    def call
      count = @department.employees.kept.count
      raise InUseError.new(count) if count.positive?

      @department.soft_delete!
    end
  end
end
