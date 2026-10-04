# JSON for a pay item in the catalogue.
class SalaryComponentSerializer
  def self.call(component)
    component.slice(:id, :code, :name, :component_type, :description).symbolize_keys
  end
end
