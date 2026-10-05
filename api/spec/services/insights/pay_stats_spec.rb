require "rails_helper"

RSpec.describe Insights::PayStats do
  let(:country) { Employee.arel_table[:country_code] }

  def stats
    described_class.new(Insights::PaidSalaries.call, group_by: country).call
  end

  it "computes headcount, total, average, median, minimum and maximum per group" do
    [ 100_000, 200_000, 600_000 ].each { |amount| paid_employee("IN", amount) }

    expect(stats["IN"]).to eq(headcount: 3, total_cost: 900_000, average: 300_000, median: 200_000,
                              minimum: 100_000, maximum: 600_000)
  end

  it "takes the mean of the two middle values for an even-sized group" do
    [ 100_000, 200_000, 300_000, 1_000_000 ].each { |amount| paid_employee("IN", amount) }
    expect(stats["IN"][:median]).to eq(250_000)
  end

  it "rounds the average to 2 decimals" do
    [ 100_000, 100_000, 100_001 ].each { |amount| paid_employee("IN", amount) }
    expect(stats["IN"][:average]).to eq(BigDecimal("100000.33"))
  end

  it "keeps groups apart, so currencies are never mixed" do
    paid_employee("IN", 1_200_000)
    paid_employee("US", 90_000)
    expect(stats.transform_values { |figures| figures[:total_cost] }).to eq("IN" => 1_200_000, "US" => 90_000)
  end

  it "returns nothing when there are no salaries" do
    expect(stats).to eq({})
  end
end
