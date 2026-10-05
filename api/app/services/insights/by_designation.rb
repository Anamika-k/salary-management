# Pay figures per designation within one country, optionally one department:
# answers "what does a Software Engineer earn in India?". Highest cost first.
module Insights
  class ByDesignation
    def initialize(country:, department_id: nil)
      @country = PaidSalaries.country!(country)
      @department_id = department_id.presence
    end

    def call
      salaries = PaidSalaries.call(country: @country[:code])
      salaries = salaries.merge(Employee.in_department(@department_id)) if @department_id
      groups = PayStats.new(salaries, group_by: Employee.arel_table[:designation]).call
                       .map { |designation, figures| { designation:, **figures } }
      { country: @country, groups: groups.sort_by { |group| -group[:total_cost] } }
    end
  end
end
