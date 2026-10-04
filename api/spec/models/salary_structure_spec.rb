require "rails_helper"

RSpec.describe SalaryStructure do
  it "is valid with the factory defaults" do
    expect(build(:salary_structure)).to be_valid
  end

  it "requires a name and code" do
    structure = build(:salary_structure, name: nil, code: nil)
    expect(structure).not_to be_valid
    expect(structure.errors.attribute_names).to include(:name, :code)
  end

  it "rejects a duplicate code" do
    create(:salary_structure, code: "IN_STD")
    expect(build(:salary_structure, code: "IN_STD")).not_to be_valid
  end

  it "allows no country, but rejects an unsupported one" do
    expect(build(:salary_structure, country_code: nil)).to be_valid
    expect(build(:salary_structure, country_code: "ZZ")).not_to be_valid
  end

  it "knows its currency from its country" do
    expect(build(:salary_structure, country_code: "IN").currency).to eq("INR")
    expect(build(:salary_structure, country_code: nil).currency).to be_nil
  end

  it "lists live rules in position order" do
    structure = create(:salary_structure)
    basic = add_rule(structure, "BASIC", :percentage_of_gross, 50)
    add_rule(structure, "OLD", :fixed, 10).soft_delete!
    hra = add_rule(structure, "HRA", :percentage_of_gross, 20)
    basic.update!(position: 9)

    expect(structure.rules.reload).to eq([ hra, basic ])
  end
end
