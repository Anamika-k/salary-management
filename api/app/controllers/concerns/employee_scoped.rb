# For controllers nested under /employees/:employee_id: loads the live
# employee once (404 if missing or soft-deleted).
module EmployeeScoped
  private

  def employee
    @employee ||= Employee.kept.find(params[:employee_id])
  end
end
