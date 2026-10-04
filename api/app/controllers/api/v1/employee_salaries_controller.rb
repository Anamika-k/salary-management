# An employee's salary: pay history, recording a change (raise, promotion,
# correction...) and the monthly breakdown on a date.
module Api
  module V1
    class EmployeeSalariesController < ApplicationController
      include EmployeeScoped

      PERMITTED = %i[annual_salary salary_structure_id effective_from change_type notes].freeze

      def index
        salaries = employee.employee_salaries.kept.includes(:salary_structure, :created_by).order(effective_from: :desc)
        render_records(salaries, serializer: EmployeeSalarySerializer)
      end

      def create
        salary = Salaries::ChangeService.new(employee:, params: params.expect(salary: PERMITTED), user: current_user).call
        render_record(salary, serializer: EmployeeSalarySerializer, status: :created)
      end

      # GET /api/v1/employees/:employee_id/salaries/breakdown?on=2026-10-01 (defaults to today)
      def breakdown
        on = params[:on].present? ? params[:on].to_date : Date.current
        render json: { data: Salaries::BreakdownService.new(employee:, on:).call }
      end
    end
  end
end
