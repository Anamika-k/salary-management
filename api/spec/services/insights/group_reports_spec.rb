require "rails_helper"

RSpec.describe "Insights group reports" do
  let(:engineering) { create(:department, name: "Engineering") }
  let(:finance) { create(:department, name: "Finance") }

  describe Insights::ByCountry do
    it "gives each country's figures in its own currency, largest headcount first" do
      paid_employee("US", 90_000)
      paid_employee("IN", 1_000_000)
      paid_employee("IN", 2_000_000)

      result = described_class.new.call
      expect(result.pluck(:country_code)).to eq(%w[IN US])
      expect(result.first).to include(country_name: "India", currency: "INR", headcount: 2,
                                      total_cost: 3_000_000, median: 1_500_000)
    end
  end

  describe Insights::ByDepartment do
    it "gives each department's figures within one country, highest cost first" do
      paid_employee("IN", 1_000_000, department: engineering)
      paid_employee("IN", 3_000_000, department: finance)
      paid_employee("US", 500_000, department: engineering)

      result = described_class.new(country: "in").call
      expect(result[:country]).to eq(code: "IN", name: "India", currency: "INR")
      expect(result[:groups].map { |group| [ group[:department][:name], group[:total_cost] ] })
        .to eq([ [ "Finance", 3_000_000 ], [ "Engineering", 1_000_000 ] ])
    end

    it "rejects an unknown country" do
      expect { described_class.new(country: "XX").call }.to raise_error(Insights::UnknownCountryError)
    end
  end

  describe Insights::ByDesignation do
    before do
      paid_employee("IN", 1_000_000, designation: "Engineer", department: engineering)
      paid_employee("IN", 2_000_000, designation: "Engineer", department: engineering)
      paid_employee("IN", 800_000, designation: "Accountant", department: finance)
    end

    it "gives pay per designation within a country" do
      groups = described_class.new(country: "IN").call[:groups]
      expect(groups.map { |group| [ group[:designation], group[:headcount], group[:average] ] })
        .to eq([ [ "Engineer", 2, 1_500_000 ], [ "Accountant", 1, 800_000 ] ])
    end

    it "narrows to one department when asked" do
      groups = described_class.new(country: "IN", department_id: finance.id).call[:groups]
      expect(groups.pluck(:designation)).to eq([ "Accountant" ])
    end
  end
end
