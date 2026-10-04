# Everything the employee list's dropdowns need, in one small payload, so the
# UI never downloads employees just to build a filter.
module Employees
  class FilterOptionsService
    def call
      {
        departments: Department.kept.order(:name).map { |department| department.slice(:id, :name).symbolize_keys },
        countries: Country.all,
        designations: Employee.kept.distinct.order(:designation).pluck(:designation),
        employment_statuses: Employee.employment_statuses.keys
      }
    end
  end
end
