# Creates an employee and assigns the next employee code (EMP000001, ...).
# Codes are never typed by HR, so they stay unique and in sequence; the
# unique index is the final guard if two creates ever race.
module Employees
  class CreateService
    CODE_PREFIX = "EMP".freeze

    def initialize(attributes)
      @attributes = attributes.to_h.symbolize_keys.except(:employee_code)
    end

    def call
      Employee.create!(@attributes.merge(employee_code: next_code))
    end

    private

    # Includes soft-deleted employees so a code is never reused.
    def next_code
      last_number = Employee.maximum(:employee_code).to_s.delete_prefix(CODE_PREFIX).to_i
      format("#{CODE_PREFIX}%06d", last_number + 1)
    end
  end
end
