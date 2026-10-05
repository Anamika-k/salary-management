# Pay figures per department within one country (one currency). Highest cost first.
module Insights
  class ByDepartment
    def initialize(country:)
      @country = PaidSalaries.country!(country)
    end

    def call
      stats = PayStats.new(PaidSalaries.call(country: @country[:code]), group_by: Employee.arel_table[:department_id]).call
      names = Department.where(id: stats.keys).pluck(:id, :name).to_h
      groups = stats.map { |id, figures| { department: { id:, name: names[id] }, **figures } }
      { country: @country, groups: groups.sort_by { |group| -group[:total_cost] } }
    end
  end
end
