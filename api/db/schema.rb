# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_10_04_120008) do
  create_table "audit_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "action", null: false
    t.string "auditable_type", null: false
    t.bigint "auditable_id", null: false
    t.json "change_set", null: false
    t.datetime "created_at", null: false
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable"
    t.index ["created_at"], name: "index_audit_logs_on_created_at"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
    t.check_constraint "`action` in (_utf8mb4'created',_utf8mb4'updated',_utf8mb4'deleted',_utf8mb4'restored')", name: "audit_logs_action_check"
  end

  create_table "departments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "employee_salaries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.bigint "salary_structure_id", null: false
    t.decimal "annual_salary", precision: 15, scale: 2, null: false
    t.string "currency", limit: 3, null: false
    t.date "effective_from", null: false
    t.date "effective_to"
    t.string "change_type", null: false
    t.text "notes"
    t.bigint "created_by_id", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "live_effective_from", type: :date, as: "if((`deleted_at` is null),`effective_from`,NULL)", stored: true
    t.virtual "open_marker", type: :integer, limit: 1, as: "if(((`deleted_at` is null) and (`effective_to` is null)),1,NULL)", stored: true
    t.index ["created_by_id"], name: "index_employee_salaries_on_created_by_id"
    t.index ["effective_from", "effective_to"], name: "index_employee_salaries_on_effective_from_and_effective_to"
    t.index ["employee_id", "effective_to"], name: "index_employee_salaries_on_employee_id_and_effective_to"
    t.index ["employee_id", "live_effective_from"], name: "index_employee_salaries_on_employee_and_live_from", unique: true
    t.index ["employee_id", "open_marker"], name: "index_employee_salaries_one_open_per_employee", unique: true
    t.index ["employee_id"], name: "index_employee_salaries_on_employee_id"
    t.index ["salary_structure_id"], name: "index_employee_salaries_on_salary_structure_id"
    t.check_constraint "(`effective_to` is null) or (`effective_to` >= `effective_from`)", name: "employee_salaries_period_order_check"
    t.check_constraint "`annual_salary` > 0", name: "employee_salaries_annual_salary_positive_check"
    t.check_constraint "`change_type` in (_utf8mb4'joining',_utf8mb4'increment',_utf8mb4'promotion',_utf8mb4'adjustment',_utf8mb4'correction')", name: "employee_salaries_change_type_check"
  end

  create_table "employees", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "employee_code", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "country_code", limit: 2, null: false
    t.bigint "department_id", null: false
    t.string "designation", null: false
    t.date "joining_date", null: false
    t.string "employment_status", default: "active", null: false
    t.date "exit_date"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_code"], name: "index_employees_on_country_code"
    t.index ["department_id"], name: "index_employees_on_department_id"
    t.index ["designation"], name: "index_employees_on_designation"
    t.index ["email"], name: "index_employees_on_email", unique: true
    t.index ["employee_code"], name: "index_employees_on_employee_code", unique: true
    t.index ["employment_status"], name: "index_employees_on_employment_status"
    t.index ["first_name"], name: "index_employees_on_first_name"
    t.index ["last_name"], name: "index_employees_on_last_name"
    t.check_constraint "(`employment_status` = _utf8mb4'terminated') = (`exit_date` is not null)", name: "employees_exit_date_iff_terminated_check"
    t.check_constraint "(`exit_date` is null) or (`exit_date` >= `joining_date`)", name: "employees_exit_after_joining_check"
    t.check_constraint "`employment_status` in (_utf8mb4'active',_utf8mb4'on_leave',_utf8mb4'terminated')", name: "employees_employment_status_check"
  end

  create_table "salary_components", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "component_type", null: false
    t.text "description"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_salary_components_on_code", unique: true
    t.check_constraint "`component_type` in (_utf8mb4'earning',_utf8mb4'deduction')", name: "salary_components_component_type_check"
  end

  create_table "salary_structure_components", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "salary_structure_id", null: false
    t.bigint "salary_component_id", null: false
    t.string "calculation_method", null: false
    t.decimal "value", precision: 15, scale: 4
    t.bigint "base_component_id"
    t.integer "position", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.virtual "live_component_id", type: :bigint, as: "if((`deleted_at` is null),`salary_component_id`,NULL)", stored: true
    t.virtual "live_position", type: :integer, as: "if((`deleted_at` is null),`position`,NULL)", stored: true
    t.index ["base_component_id"], name: "index_salary_structure_components_on_base_component_id"
    t.index ["salary_component_id"], name: "index_salary_structure_components_on_salary_component_id"
    t.index ["salary_structure_id", "live_component_id"], name: "index_ssc_on_structure_and_live_component", unique: true
    t.index ["salary_structure_id", "live_position"], name: "index_ssc_on_structure_and_live_position", unique: true
    t.index ["salary_structure_id"], name: "index_salary_structure_components_on_salary_structure_id"
    t.check_constraint "(`calculation_method` = _utf8mb4'percentage_of_component') = (`base_component_id` is not null)", name: "ssc_base_component_iff_percentage_check"
    t.check_constraint "(`calculation_method` = _utf8mb4'remainder') or (`value` is not null)", name: "ssc_value_required_check"
    t.check_constraint "(`value` is null) or (`value` >= 0)", name: "ssc_value_non_negative_check"
    t.check_constraint "`calculation_method` in (_utf8mb4'fixed',_utf8mb4'percentage_of_gross',_utf8mb4'percentage_of_component',_utf8mb4'remainder')", name: "ssc_calculation_method_check"
    t.check_constraint "`position` > 0", name: "ssc_position_positive_check"
  end

  create_table "salary_structures", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.string "country_code", limit: 2
    t.text "description"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_salary_structures_on_code", unique: true
    t.index ["country_code"], name: "index_salary_structures_on_country_code"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "jti", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
  end

  add_foreign_key "audit_logs", "users"
  add_foreign_key "employee_salaries", "employees"
  add_foreign_key "employee_salaries", "salary_structures"
  add_foreign_key "employee_salaries", "users", column: "created_by_id"
  add_foreign_key "employees", "departments"
  add_foreign_key "salary_structure_components", "salary_components"
  add_foreign_key "salary_structure_components", "salary_components", column: "base_component_id"
  add_foreign_key "salary_structure_components", "salary_structures"
end
