require "rails_helper"

RSpec.describe ApplicationError do
  it "defaults to 422" do
    expect(described_class.new.status).to eq(:unprocessable_content)
  end

  it "derives a snake_case code from the class name, without namespace" do
    stub_const("Salaries::OverlapError", Class.new(described_class))
    expect(Salaries::OverlapError.new.code).to eq("overlap_error")
  end

  it "has no details by default" do
    expect(described_class.new.details).to eq({})
  end

  it "accepts details for the response" do
    error = described_class.new("Bad", details: { from: [ "overlaps" ] })
    expect(error.details).to eq(from: [ "overlaps" ])
  end
end
