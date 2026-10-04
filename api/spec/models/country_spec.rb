require "rails_helper"

RSpec.describe Country do
  it "lists supported country codes" do
    expect(described_class.codes).to include("IN", "US", "GB")
  end

  it "knows each country's name and currency" do
    expect(described_class.find("IN")).to eq(code: "IN", name: "India", currency: "INR")
  end

  it "returns nil for an unsupported code" do
    expect(described_class.find("ZZ")).to be_nil
  end

  it "lists every country with its details" do
    expect(described_class.all).to include(code: "US", name: "United States", currency: "USD")
  end
end
