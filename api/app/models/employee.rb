# A person ACME pays. Leaving the company is the "terminated" status with an
# exit date (kept for history); soft delete is only for records made by mistake.
# Validations mirror the database constraints so users get readable errors.
class Employee < ApplicationRecord
  include SoftDeletable

  SEARCHABLE_COLUMNS = %i[first_name last_name email employee_code].freeze

  belongs_to :department
  has_many :employee_salaries
  # The live salary in effect today; preloadable, so lists avoid N+1.
  has_one :current_salary, -> { kept.as_of(Date.current) }, class_name: "EmployeeSalary"

  enum :employment_status, { active: "active", on_leave: "on_leave", terminated: "terminated" }, validate: true

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :country_code, with: ->(code) { code.strip.upcase }

  validates :employee_code, :first_name, :last_name, :designation, :joining_date, presence: true
  validates :employee_code, uniqueness: true
  validates :email, presence: true, uniqueness: { case_sensitive: false, conditions: -> { kept } },
                    format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :country_code, presence: true
  validates :country_code, inclusion: { in: Country.codes, message: "is not supported" }, allow_blank: true
  validates :exit_date, presence: true, if: :terminated?
  validates :exit_date, absence: true, unless: :terminated?
  validate :exit_date_not_before_joining
  validate :department_not_deleted

  scope :in_department, ->(id) { where(department_id: id) }
  scope :in_country, ->(code) { where(country_code: code.to_s.upcase) }
  scope :with_status, ->(status) { where(employment_status: status) }
  scope :with_designation, ->(designation) { where(designation:) }

  # Every word must match the start or middle of a name, email or code,
  # so "asha verma" finds Asha Verma. LIKE wildcards in the input are escaped.
  def self.search(query)
    query.to_s.split.reduce(all) do |scope, word|
      pattern = "%#{sanitize_sql_like(word)}%"
      scope.where(SEARCHABLE_COLUMNS.map { |column| arel_table[column].matches(pattern) }.reduce(:or))
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def exit_date_not_before_joining
    return unless exit_date && joining_date && exit_date < joining_date

    errors.add(:exit_date, "can't be before the joining date")
  end

  def department_not_deleted
    errors.add(:department, "is deleted") if department&.deleted?
  end
end
