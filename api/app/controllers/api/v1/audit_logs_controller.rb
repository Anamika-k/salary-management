# An employee's salary audit trail: every salary created or closed, by whom
# and when, newest first.
module Api
  module V1
    class AuditLogsController < ApplicationController
      include EmployeeScoped

      def index
        logs = AuditLog.where(auditable_type: EmployeeSalary.polymorphic_name,
                              auditable_id: employee.employee_salaries.select(:id))
                       .includes(:user).order(created_at: :desc, id: :desc)
        render_records(logs, serializer: AuditLogSerializer)
      end
    end
  end
end
