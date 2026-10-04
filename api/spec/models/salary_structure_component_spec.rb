require "rails_helper"

RSpec.describe SalaryStructureComponent do
  let(:structure) { create(:salary_structure) }
  let!(:basic) { add_rule(structure, "BASIC", :percentage_of_gross, 50) }

  def build_rule(method, value = nil, type: :earning, base: nil, position: 10)
    build(:salary_structure_component, salary_structure: structure, calculation_method: method, value:, position:,
                                       salary_component: create(:salary_component, component_type: type),
                                       base_component: base)
  end

  it "is valid with the factory defaults" do
    expect(basic).to be_valid
  end

  it "rejects an unknown calculation method" do
    expect(build_rule("magic", 1)).not_to be_valid
  end

  describe "value" do
    it "is required unless remainder" do
      expect(build_rule(:fixed, nil)).not_to be_valid
    end

    it "must be blank for remainder" do
      expect(build_rule(:remainder, 5)).not_to be_valid
    end

    it "can't be negative" do
      expect(build_rule(:fixed, -1)).not_to be_valid
    end

    it "can't exceed 100 for a percentage, but can for a fixed amount" do
      expect(build_rule(:percentage_of_gross, 101)).not_to be_valid
      expect(build_rule(:fixed, 5000)).to be_valid
    end
  end

  describe "base component" do
    it "is required for percentage_of_component only" do
      expect(build_rule(:percentage_of_component, 12)).not_to be_valid
      expect(build_rule(:fixed, 100, base: basic.salary_component)).not_to be_valid
    end

    it "must be an earlier rule in the same structure" do
      expect(build_rule(:percentage_of_component, 12, base: basic.salary_component)).to be_valid
      expect(build_rule(:percentage_of_component, 12, base: basic.salary_component, position: 1)).not_to be_valid
      expect(build_rule(:percentage_of_component, 12, base: create(:salary_component))).not_to be_valid
    end
  end

  describe "remainder" do
    it "is only for earnings" do
      expect(build_rule(:remainder, type: :deduction)).not_to be_valid
    end

    it "is allowed once per structure and must be the last earning" do
      add_rule(structure, "SPECIAL", :remainder)
      expect(build_rule(:remainder, position: 20)).not_to be_valid
      expect(build_rule(:fixed, 100, position: 20)).not_to be_valid
      expect(build_rule(:fixed, 100, type: :deduction, position: 20)).to be_valid
    end
  end

  it "rejects the same component twice in a structure" do
    duplicate = build_rule(:fixed, 100)
    duplicate.salary_component = basic.salary_component
    expect(duplicate).not_to be_valid
  end
end
