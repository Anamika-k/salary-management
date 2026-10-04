# Turns an annual salary into the standard monthly breakdown using a salary
# structure's rules. All salary math lives here so rules change in one place.
# Pure calculation: no database writes. Each line is rounded half up to 2
# decimals; the remainder earning absorbs rounding so earnings equal gross exactly.
module Salaries
  class Calculator
    def initialize(annual_salary:, structure:)
      @annual_salary = BigDecimal(annual_salary.to_s, exception: false)
      @structure = structure
    end

    def call
      raise BreakdownError, "Annual salary must be a positive number" unless @annual_salary&.positive?

      gross = round(@annual_salary / 12)
      lines = calculate_lines(gross)
      earnings, deductions = lines.partition { |line| line[:component_type] == "earning" }
      breakdown(gross, earnings, deductions)
    end

    private

    # Rules run in position order, so a percentage can use any earlier amount.
    def calculate_lines(gross)
      @amounts = {}
      @earned = BigDecimal(0)
      @structure.rules.map do |rule|
        amount = amount_for(rule, gross)
        @amounts[rule.salary_component_id] = amount
        @earned += amount if rule.earning?
        { code: rule.salary_component.code, name: rule.salary_component.name,
          component_type: rule.salary_component.component_type, amount: }
      end
    end

    def amount_for(rule, gross)
      case rule.calculation_method
      when "fixed" then round(rule.value)
      when "percentage_of_gross" then round(gross * rule.value / 100)
      when "percentage_of_component" then round(@amounts.fetch(rule.base_component_id) * rule.value / 100)
      when "remainder" then remainder(gross)
      end
    end

    # Every other earning comes before the remainder (validated on the rule).
    def remainder(gross)
      left = gross - @earned
      raise BreakdownError, "Earnings exceed the monthly gross of #{gross}" if left.negative?

      left
    end

    def breakdown(gross, earnings, deductions)
      total_earnings = earnings.sum(BigDecimal(0)) { |line| line[:amount] }
      total_deductions = deductions.sum(BigDecimal(0)) { |line| line[:amount] }
      raise BreakdownError, "Earnings don't add up to the monthly gross; add a remainder earning" if total_earnings != gross
      raise BreakdownError, "Deductions exceed the monthly gross pay" if total_deductions > gross

      { annual_salary: @annual_salary, currency: @structure.currency, monthly_gross: gross,
        earnings: earnings.map { |line| line.except(:component_type) },
        deductions: deductions.map { |line| line.except(:component_type) },
        total_earnings:, total_deductions:, net_pay: gross - total_deductions }
    end

    def round(amount)
      amount.round(2, half: :up)
    end
  end
end
