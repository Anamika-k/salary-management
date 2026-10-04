# Departments HR manages. A table (not a text column) so renames are one
# update and insights group by a stable id. Deleted ones are restored, not
# recreated, so name uniqueness is global.
class CreateDepartments < ActiveRecord::Migration[8.0]
  def change
    create_table :departments do |t|
      t.string :name, null: false
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :departments, :name, unique: true
  end
end
