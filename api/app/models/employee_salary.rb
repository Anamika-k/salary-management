# One period of an employee's pay: the annual gross salary, its currency and
# structure, valid from effective_from to effective_to (nil = still current).
# A change adds a new row and closes the old one (Salaries::ChangeService), so
# history is never overwritten.
class EmployeeSalary < ApplicationRecord
  include SoftDeletable

  belongs_to :employee
  belongs_to :salary_structure
  belongs_to :created_by, class_name: "User"

  enum :change_type, { joining: "joining", increment: "increment", promotion: "promotion",
                       adjustment: "adjustment", correction: "correction" }, prefix: true, validate: true

  validates :annual_salary, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true, length: { is: 3 }
  validates :effective_from, presence: true
  validates :effective_to, comparison: { greater_than_or_equal_to: :effective_from }, allow_nil: true,
                           if: :effective_from

  # Salaries in effect on a date (both boundary days included).
  scope :as_of, ->(date) {
    where(effective_from: ..date).merge(where(effective_to: nil).or(where(effective_to: date..)))
  }
end
