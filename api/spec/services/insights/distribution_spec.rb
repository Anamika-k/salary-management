require "rails_helper"

RSpec.describe Insights::Distribution do
  def distribution(country = "IN")
    described_class.new(country:).call
  end

  it "splits a country's salaries into round, equal-width bands covering everyone" do
    [ 310_000, 420_000, 450_000, 980_000, 1_190_000 ].each { |amount| paid_employee("IN", amount) }

    result = distribution
    bands = result[:bands]
    expect(result).to include(currency: "INR", headcount: 5)
    expect(bands.first[:from]).to eq(300_000)
    expect(bands.map { |band| band[:to] - band[:from] }.uniq).to eq([ 100_000 ])
    expect(bands.sum { |band| band[:count] }).to eq(5)
    expect(bands.last[:to]).to be > 1_190_000
    expect(bands.find { |band| band[:from] == 400_000 }[:count]).to eq(2)
  end

  it "puts a salary exactly on a boundary into the higher band" do
    [ 100_000, 200_000, 900_000 ].each { |amount| paid_employee("IN", amount) }
    expect(distribution[:bands].find { |band| band[:from] == 200_000 }[:count]).to eq(1)
  end

  it "uses a single band when everyone earns the same" do
    2.times { paid_employee("IN", 500_000) }
    expect(distribution[:bands]).to eq([ { from: 500_000, to: 500_001, count: 2 } ])
  end

  it "returns no bands for a country without salaries" do
    expect(distribution("SG")).to include(headcount: 0, bands: [])
  end

  it "rejects an unknown country" do
    expect { distribution("XX") }.to raise_error(Insights::UnknownCountryError)
  end
end
