# A salary structure without its rules, for the structures list.
class SalaryStructureLiteSerializer
  def self.call(structure)
    structure.slice(:id, :code, :name, :country_code, :description).symbolize_keys.merge(currency: structure.currency)
  end
end
