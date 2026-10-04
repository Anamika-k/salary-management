require "rails_helper"

RSpec.describe SalaryComponent do
  it "is valid with the factory defaults" do
    expect(build(:salary_component)).to be_valid
  end

  it "requires a name and code" do
    component = build(:salary_component, name: nil, code: nil)
    expect(component).not_to be_valid
    expect(component.errors.attribute_names).to include(:name, :code)
  end

  it "rejects a duplicate code" do
    create(:salary_component, code: "PF")
    expect(build(:salary_component, code: "PF")).not_to be_valid
  end

  it "accepts only earning or deduction" do
    expect(build(:salary_component, component_type: "bonus")).not_to be_valid
  end
end
