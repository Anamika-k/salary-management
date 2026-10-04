# Salary structures (seeded per country): list, detail with rules, and a
# preview of the monthly breakdown for any annual salary.
module Api
  module V1
    class SalaryStructuresController < ApplicationController
      def index
        render_records(SalaryStructure.kept.order(:name), serializer: SalaryStructureLiteSerializer)
      end

      def show
        render_record(structure, serializer: SalaryStructureSerializer)
      end

      # GET /api/v1/salary_structures/:id/preview?annual_salary=1200000
      def preview
        breakdown = Salaries::Calculator.new(annual_salary: params.require(:annual_salary), structure:).call
        render json: { data: breakdown }
      end

      private

      def structure
        @structure ||= SalaryStructure.kept.includes(rules: %i[salary_component base_component]).find(params[:id])
      end
    end
  end
end
