# Departments HR manages: list, create (restores a deleted one with the same
# name), rename and soft delete (refused while employees belong to it).
module Api
  module V1
    class DepartmentsController < ApplicationController
      def index
        render_records(Department.kept.order(:name), serializer: DepartmentSerializer)
      end

      def create
        department = Departments::CreateService.new(name: department_params[:name]).call
        render_record(department, serializer: DepartmentSerializer, status: :created)
      end

      def update
        department.update!(department_params)
        render_record(department, serializer: DepartmentSerializer)
      end

      def destroy
        Departments::DeleteService.new(department).call
        head :no_content
      end

      private

      def department
        @department ||= Department.kept.find(params[:id])
      end

      def department_params
        params.expect(department: [ :name ])
      end
    end
  end
end
