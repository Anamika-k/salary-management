# The people being paid. Salary amounts deliberately live in employee_salaries
# so history is never overwritten. "terminated" is a status (kept in history);
# deleted_at is only for records created by mistake.
class CreateEmployees < ActiveRecord::Migration[8.0]
  def change
    create_table :employees do |t|
      t.string :employee_code, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :country_code, limit: 2, null: false
      t.references :department, null: false, foreign_key: true
      t.string :designation, null: false
      t.date :joining_date, null: false
      t.string :employment_status, null: false, default: "active"
      t.date :exit_date
      t.datetime :deleted_at
      t.timestamps

      t.check_constraint "employment_status IN ('active', 'on_leave', 'terminated')",
                         name: "employees_employment_status_check"
      t.check_constraint "exit_date IS NULL OR exit_date >= joining_date",
                         name: "employees_exit_after_joining_check"
      t.check_constraint "(employment_status = 'terminated') = (exit_date IS NOT NULL)",
                         name: "employees_exit_date_iff_terminated_check"
    end

    add_index :employees, :employee_code, unique: true
    add_index :employees, :email, unique: true
    add_index :employees, :country_code
    add_index :employees, :employment_status
    add_index :employees, :designation
    add_index :employees, :first_name
    add_index :employees, :last_name
  end
end
