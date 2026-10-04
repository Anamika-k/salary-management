# One rule in a salary structure: how a component is calculated (fixed, % of
# gross, % of an earlier component, or the remainder of gross) and in what order.
# The shape rules below keep every structure calculable in a single ordered pass.
class SalaryStructureComponent < ApplicationRecord
  include SoftDeletable

  belongs_to :salary_structure
  belongs_to :salary_component
  belongs_to :base_component, class_name: "SalaryComponent", optional: true

  enum :calculation_method, { fixed: "fixed", percentage_of_gross: "percentage_of_gross",
                              percentage_of_component: "percentage_of_component", remainder: "remainder" },
       validate: true

  delegate :earning?, to: :salary_component, allow_nil: true

  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :position, uniqueness: { scope: :salary_structure_id, conditions: -> { kept } }
  validates :salary_component_id, uniqueness: { scope: :salary_structure_id, conditions: -> { kept } }
  validates :value, presence: true, numericality: { greater_than_or_equal_to: 0 }, unless: :remainder?
  validates :value, numericality: { less_than_or_equal_to: 100 }, if: :percentage?
  validates :value, absence: true, if: :remainder?
  validates :base_component, presence: true, if: :percentage_of_component?
  validates :base_component, absence: true, unless: :percentage_of_component?
  validate :base_component_comes_earlier, if: -> { percentage_of_component? && base_component }
  validate :remainder_is_last_earning, if: :earning?
  validate :remainder_only_for_earnings, if: :remainder?

  def percentage?
    percentage_of_gross? || percentage_of_component?
  end

  private

  def live_siblings
    SalaryStructureComponent.kept.where(salary_structure_id:).where.not(id:)
  end

  def base_component_comes_earlier
    return if live_siblings.exists?(salary_component: base_component, position: ...position.to_i)

    errors.add(:base_component, "must be an earlier component in the same structure")
  end

  # The remainder is calculated from every other earning, so it must come after them all.
  def remainder_is_last_earning
    earnings = live_siblings.joins(:salary_component).where(salary_components: { component_type: "earning" })
    if remainder?
      errors.add(:calculation_method, "remainder is allowed once per structure") if earnings.remainder.exists?
      errors.add(:position, "must come after every other earning") if earnings.exists?(position: position.to_i..)
    elsif earnings.remainder.exists?(position: ..position.to_i)
      errors.add(:position, "must come before the remainder earning")
    end
  end

  def remainder_only_for_earnings
    errors.add(:calculation_method, "remainder is only for earnings") unless earning?
  end
end
