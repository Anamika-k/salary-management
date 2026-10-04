# Creates a department, or restores a soft-deleted one with the same name.
# Names are unique across deleted rows, so restoring is how a department "comes back".
module Departments
  class CreateService
    def initialize(name:)
      @name = name.to_s.strip
    end

    def call
      deleted = Department.deleted.find_by(name: @name) if @name.present?
      return deleted.tap(&:restore!) if deleted

      Department.create!(name: @name)
    end
  end
end
