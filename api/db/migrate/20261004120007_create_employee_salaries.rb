# Salary history: one row per salary period per employee; a change adds a row
# and closes the previous one. Generated columns emulate partial unique indexes
# (MySQL has none): one start date per employee and at most one open salary,
# both ignoring soft-deleted rows. Overlap prevention lives in the service.
class CreateEmployeeSalaries < ActiveRecord::Migration[8.0]
  def change
    create_table :employee_salaries do |t|
      t.references :employee, null: false, foreign_key: true
      t.references :salary_structure, null: false, foreign_key: true
      t.decimal :annual_salary, precision: 15, scale: 2, null: false
      t.string :currency, limit: 3, null: false
      t.date :effective_from, null: false
      t.date :effective_to
      t.string :change_type, null: false
      t.text :notes
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.datetime :deleted_at
      t.timestamps

      t.virtual :live_effective_from, type: :date, stored: true,
                as: "IF(deleted_at IS NULL, effective_from, NULL)"
      t.virtual :open_marker, type: :integer, limit: 1, stored: true,
                as: "IF(deleted_at IS NULL AND effective_to IS NULL, 1, NULL)"

      t.check_constraint "annual_salary > 0", name: "employee_salaries_annual_salary_positive_check"
      t.check_constraint "effective_to IS NULL OR effective_to >= effective_from",
                         name: "employee_salaries_period_order_check"
      t.check_constraint "change_type IN ('joining', 'increment', 'promotion', 'adjustment', 'correction')",
                         name: "employee_salaries_change_type_check"
    end

    add_index :employee_salaries, %i[employee_id live_effective_from],
              unique: true, name: "index_employee_salaries_on_employee_and_live_from"
    add_index :employee_salaries, %i[employee_id open_marker],
              unique: true, name: "index_employee_salaries_one_open_per_employee"
    add_index :employee_salaries, %i[employee_id effective_to]
    add_index :employee_salaries, %i[effective_from effective_to]
  end
end
