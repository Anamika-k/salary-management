# Builds salary structures rule by rule in specs, e.g.
#   add_rule(structure, "BASIC", :percentage_of_gross, 50)
#   add_rule(structure, "PF", :percentage_of_component, 12, type: :deduction, base: "BASIC")
module SalaryStructureHelpers
  def add_rule(structure, code, method, value = nil, type: :earning, base: nil)
    component = SalaryComponent.find_by(code:) || create(:salary_component, code:, name: code, component_type: type)
    create(:salary_structure_component,
           salary_structure: structure, salary_component: component, calculation_method: method, value:,
           base_component: base && SalaryComponent.find_by!(code: base),
           position: structure.rules.maximum(:position).to_i + 1)
  end
end

RSpec.configure do |config|
  config.include SalaryStructureHelpers
end
