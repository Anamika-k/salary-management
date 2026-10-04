# One rule of a salary structure: which component, how it's calculated and
# (for percentage_of_component) what it's a percentage of.
class SalaryStructureComponentSerializer
  def self.call(rule)
    {
      id: rule.id,
      position: rule.position,
      calculation_method: rule.calculation_method,
      value: rule.value,
      component: rule.salary_component.slice(:id, :code, :name, :component_type),
      base_component: rule.base_component&.slice(:id, :code, :name)
    }
  end
end
