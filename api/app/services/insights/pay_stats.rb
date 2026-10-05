# Headcount, total cost, average, median, minimum and maximum of annual salary
# for each group (country, department, designation...). Shared by every report
# so the maths lives in one place. Returns { group_key => figures }.
# MySQL has no MEDIAN, so medians come from the sorted amounts in Ruby: one
# extra query of a few thousand decimals at most.
module Insights
  class PayStats
    AMOUNT = EmployeeSalary.arel_table[:annual_salary]

    def initialize(salaries, group_by:)
      @salaries = salaries
      @column = group_by
    end

    def call
      medians = medians_by_group
      aggregates.to_h do |key, count, total, average, minimum, maximum|
        [ key, { headcount: count, total_cost: total, average: average.round(2), median: medians[key],
                 minimum:, maximum: } ]
      end
    end

    private

    def aggregates
      @salaries.group(@column).pluck(@column, AMOUNT.count, AMOUNT.sum, AMOUNT.average, AMOUNT.minimum, AMOUNT.maximum)
    end

    def medians_by_group
      @salaries.order(@column, AMOUNT).pluck(@column, AMOUNT)
               .group_by(&:first)
               .transform_values { |rows| median(rows.map(&:last)) }
    end

    def median(sorted)
      middle = sorted.size / 2
      sorted.size.odd? ? sorted[middle] : ((sorted[middle - 1] + sorted[middle]) / 2).round(2)
    end
  end
end
