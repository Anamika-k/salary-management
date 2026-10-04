# Catalogue of pay items (Basic, HRA, PF, Tax...). Says WHAT an item is;
# HOW it is calculated belongs to salary_structure_components.
class CreateSalaryComponents < ActiveRecord::Migration[8.0]
  def change
    create_table :salary_components do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :component_type, null: false
      t.text :description
      t.datetime :deleted_at
      t.timestamps

      t.check_constraint "component_type IN ('earning', 'deduction')",
                         name: "salary_components_component_type_check"
    end

    add_index :salary_components, :code, unique: true
  end
end
