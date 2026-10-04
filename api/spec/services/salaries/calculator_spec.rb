require "rails_helper"

RSpec.describe Salaries::Calculator do
  let(:structure) { create(:salary_structure, country_code: "IN") }

  def india_rules
    add_rule(structure, "BASIC", :percentage_of_gross, 50)
    add_rule(structure, "HRA", :percentage_of_component, 40, base: "BASIC")
    add_rule(structure, "SPECIAL", :remainder)
    add_rule(structure, "PF", :percentage_of_component, 12, type: :deduction, base: "BASIC")
    add_rule(structure, "PROF_TAX", :fixed, 200, type: :deduction)
    add_rule(structure, "INCOME_TAX", :percentage_of_gross, 10, type: :deduction)
  end

  def calculate(annual_salary)
    described_class.new(annual_salary:, structure: structure.reload).call
  end

  def amounts(lines)
    lines.to_h { |line| [ line[:code], line[:amount] ] }
  end

  it "breaks an annual salary into monthly earnings, deductions and net pay" do
    india_rules
    result = calculate(1_200_000)

    expect(result).to include(annual_salary: 1_200_000, monthly_gross: 100_000, currency: "INR",
                              total_earnings: 100_000, total_deductions: 16_200, net_pay: 83_800)
    expect(amounts(result[:earnings])).to eq("BASIC" => 50_000, "HRA" => 20_000, "SPECIAL" => 30_000)
    expect(amounts(result[:deductions])).to eq("PF" => 6_000, "PROF_TAX" => 200, "INCOME_TAX" => 10_000)
  end

  it "rounds each line half up to 2 decimals and the remainder absorbs the difference" do
    india_rules
    result = calculate(1_000_000)

    expect(result[:monthly_gross]).to eq(BigDecimal("83333.33"))
    expect(amounts(result[:earnings])).to eq("BASIC" => BigDecimal("41666.67"), "HRA" => BigDecimal("16666.67"),
                                             "SPECIAL" => BigDecimal("24999.99"))
    expect(result[:total_earnings]).to eq(result[:monthly_gross])
  end

  it "returns money as BigDecimal, never Float" do
    india_rules
    expect(calculate("1000000.50").values_at(:monthly_gross, :net_pay)).to all(be_a(BigDecimal))
  end

  it "keeps the remainder correct when a deduction comes before it" do
    add_rule(structure, "BASIC", :percentage_of_gross, 50)
    add_rule(structure, "PF", :percentage_of_component, 12, type: :deduction, base: "BASIC")
    add_rule(structure, "SPECIAL", :remainder)
    expect(amounts(calculate(120_000)[:earnings])).to eq("BASIC" => 5_000, "SPECIAL" => 5_000)
  end

  it "ignores soft-deleted rules" do
    india_rules
    SalaryComponent.find_by!(code: "PROF_TAX").salary_structure_components.first.soft_delete!
    expect(amounts(calculate(1_200_000)[:deductions]).keys).to eq(%w[PF INCOME_TAX])
  end

  it "has no currency for a structure without a country" do
    structure.update!(country_code: nil)
    add_rule(structure, "BASIC", :percentage_of_gross, 100)
    expect(calculate(120_000)[:currency]).to be_nil
  end

  describe "impossible breakdowns" do
    it "rejects a salary that isn't a positive number" do
      india_rules
      [ 0, -5, "abc", nil ].each do |bad|
        expect { calculate(bad) }.to raise_error(Salaries::BreakdownError, /positive number/)
      end
    end

    it "rejects earnings that exceed gross" do
      add_rule(structure, "BASIC", :fixed, 10_000)
      add_rule(structure, "SPECIAL", :remainder)
      expect { calculate(60_000) }.to raise_error(Salaries::BreakdownError, /exceed/)
    end

    it "rejects earnings that don't add up to gross" do
      add_rule(structure, "BASIC", :percentage_of_gross, 50)
      expect { calculate(120_000) }.to raise_error(Salaries::BreakdownError, /add up/)
    end

    it "rejects a structure with no earnings at all" do
      expect { calculate(120_000) }.to raise_error(Salaries::BreakdownError, /add up/)
    end

    it "rejects deductions bigger than gross pay" do
      india_rules
      expect { calculate(1_200) }.to raise_error(Salaries::BreakdownError, /Deductions/)
    end
  end
end
