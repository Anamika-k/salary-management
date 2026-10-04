# Dropdown options for the employee list (departments, countries, designations,
# statuses) in one small request.
module Api
  module V1
    class FiltersController < ApplicationController
      def show
        render json: { data: Employees::FilterOptionsService.new.call }
      end
    end
  end
end
