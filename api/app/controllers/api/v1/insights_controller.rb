# Pay insights for HR: headline numbers, pay by country / department /
# designation, salary distribution and recent changes. Reports that compare
# amounts take a country, so currencies are never mixed.
module Api
  module V1
    class InsightsController < ApplicationController
      def summary
        render json: { data: Insights::Summary.new.call }
      end

      def by_country
        render json: { data: Insights::ByCountry.new.call }
      end

      def by_department
        render json: { data: Insights::ByDepartment.new(country: params.require(:country)).call }
      end

      def by_designation
        render json: { data: Insights::ByDesignation.new(country: params.require(:country),
                                                         department_id: params[:department_id]).call }
      end

      def distribution
        render json: { data: Insights::Distribution.new(country: params.require(:country)).call }
      end

      def recent_changes
        render json: { data: Insights::RecentChanges.new(country: params[:country], limit: params[:limit]).call }
      end
    end
  end
end
