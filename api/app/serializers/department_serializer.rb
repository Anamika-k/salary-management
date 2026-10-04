# JSON for a department, in lists and on its own.
class DepartmentSerializer
  def self.call(department)
    { id: department.id, name: department.name }
  end
end
