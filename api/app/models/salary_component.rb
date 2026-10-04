# A pay item in the catalogue (Basic, HRA, PF, Income Tax...). Says WHAT an
# item is; HOW much it is lives in each structure's rules.
class SalaryComponent < ApplicationRecord
  include SoftDeletable

  has_many :salary_structure_components

  enum :component_type, { earning: "earning", deduction: "deduction" }, validate: true

  validates :name, :code, presence: true
  validates :code, uniqueness: true
end
