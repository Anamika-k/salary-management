# How each pay item is calculated inside a structure.
# MySQL has no partial indexes, so the live_* generated columns are NULL for
# soft-deleted rows; unique indexes on them ignore deleted rules.
class CreateSalaryStructureComponents < ActiveRecord::Migration[8.0]
  def change
    create_table :salary_structure_components do |t|
      t.references :salary_structure, null: false, foreign_key: true
      t.references :salary_component, null: false, foreign_key: true
      t.string :calculation_method, null: false
      t.decimal :value, precision: 15, scale: 4
      t.references :base_component, foreign_key: { to_table: :salary_components }
      t.integer :position, null: false
      t.datetime :deleted_at
      t.timestamps

      t.virtual :live_component_id, type: :bigint, stored: true,
                as: "IF(deleted_at IS NULL, salary_component_id, NULL)"
      t.virtual :live_position, type: :integer, stored: true,
                as: "IF(deleted_at IS NULL, `position`, NULL)"

      t.check_constraint "calculation_method IN ('fixed', 'percentage_of_gross', " \
                         "'percentage_of_component', 'remainder')",
                         name: "ssc_calculation_method_check"
      t.check_constraint "value IS NULL OR value >= 0", name: "ssc_value_non_negative_check"
      t.check_constraint "calculation_method = 'remainder' OR value IS NOT NULL",
                         name: "ssc_value_required_check"
      t.check_constraint "(calculation_method = 'percentage_of_component') = (base_component_id IS NOT NULL)",
                         name: "ssc_base_component_iff_percentage_check"
      t.check_constraint "`position` > 0", name: "ssc_position_positive_check"
    end

    add_index :salary_structure_components, %i[salary_structure_id live_component_id],
              unique: true, name: "index_ssc_on_structure_and_live_component"
    add_index :salary_structure_components, %i[salary_structure_id live_position],
              unique: true, name: "index_ssc_on_structure_and_live_position"
  end
end
