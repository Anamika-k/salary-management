# Employee records: paginated lite list with search and filters, full detail,
# create (code generated), update and soft delete. Deleted employees are 404.
module Api
  module V1
    class EmployeesController < ApplicationController
      PERMITTED = %i[first_name last_name email country_code department_id designation
                     joining_date employment_status exit_date].freeze

      def index
        render_records(Employees::SearchService.new(params).call, serializer: EmployeeLiteSerializer)
      end

      def show
        render_record(employee, serializer: EmployeeSerializer)
      end

      def create
        employee = Employees::CreateService.new(employee_params).call
        render_record(employee, serializer: EmployeeSerializer, status: :created)
      end

      def update
        employee.update!(employee_params)
        render_record(employee, serializer: EmployeeSerializer)
      end

      def destroy
        employee.soft_delete!
        head :no_content
      end

      private

      def employee
        @employee ||= Employee.kept.find(params[:id])
      end

      def employee_params
        params.expect(employee: PERMITTED)
      end
    end
  end
end
