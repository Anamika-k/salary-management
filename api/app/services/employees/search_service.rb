# Builds the employee list query from request params: search, filters and an
# allow-listed sort. Filters apply only when present; unknown values simply
# match nothing. Returns a relation so the caller can paginate it.
module Employees
  class SearchService
    SORTABLE_COLUMNS = %w[employee_code first_name last_name joining_date created_at].freeze
    DEFAULT_SORT = "employee_code".freeze

    FILTERS = {
      department_id: :in_department,
      country_code: :in_country,
      employment_status: :with_status,
      designation: :with_designation
    }.freeze

    def initialize(params)
      @params = params
    end

    def call
      scope = Employee.kept.includes(:department, :current_salary).search(@params[:q])
      FILTERS.each do |param, filter|
        scope = scope.public_send(filter, @params[param]) if @params[param].present?
      end
      scope.order(sort_column => direction, id: direction)
    end

    private

    def sort_column
      SORTABLE_COLUMNS.include?(@params[:sort]) ? @params[:sort] : DEFAULT_SORT
    end

    def direction
      @params[:direction] == "desc" ? :desc : :asc
    end
  end
end
