# A salary structure with its rules in calculation order. Expects rules and
# their components to be preloaded.
class SalaryStructureSerializer
  def self.call(structure)
    SalaryStructureLiteSerializer.call(structure)
      .merge(components: structure.rules.map { |rule| SalaryStructureComponentSerializer.call(rule) })
  end
end
