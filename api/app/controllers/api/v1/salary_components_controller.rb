# The catalogue of pay items (read-only; components come from seeds).
module Api
  module V1
    class SalaryComponentsController < ApplicationController
      def index
        render_records(SalaryComponent.kept.order(:component_type, :name), serializer: SalaryComponentSerializer)
      end
    end
  end
end
