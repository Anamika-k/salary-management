# A department employees belong to (Engineering, Finance...). Names are unique
# across deleted ones too, so a deleted department is restored, never duplicated.
class Department < ApplicationRecord
  include SoftDeletable

  has_many :employees

  normalizes :name, with: ->(name) { name.strip }

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
