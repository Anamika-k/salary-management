# Pay figures per country, each in that country's own currency (amounts in
# different currencies are never added together). Largest headcount first.
module Insights
  class ByCountry
    def call
      PayStats.new(PaidSalaries.call, group_by: Employee.arel_table[:country_code]).call
              .map { |code, figures| country_row(code, figures) }
              .sort_by { |row| -row[:headcount] }
    end

    private

    def country_row(code, figures)
      country = Country.find(code)
      { country_code: code, country_name: country[:name], currency: country[:currency], **figures }
    end
  end
end
