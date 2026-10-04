# A reusable salary template ("India Standard") whose rules turn an annual
# salary into monthly earnings and deductions. Many employees share one, so a
# rule (e.g. the PF rate) changes in one place.
class SalaryStructure < ApplicationRecord
  include SoftDeletable

  has_many :rules, -> { kept.order(:position) }, class_name: "SalaryStructureComponent"

  validates :name, :code, presence: true
  validates :code, uniqueness: true
  validates :country_code, inclusion: { in: Country.codes, message: "is not supported" }, allow_nil: true

  # Fixed amounts are in this currency; nil for a country-neutral structure.
  def currency
    Country.find(country_code)&.fetch(:currency)
  end
end
