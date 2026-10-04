# Reusable salary templates ("India Standard"). Optional country_code restricts
# a structure to one country, because fixed amounts only make sense in that
# country's currency.
class CreateSalaryStructures < ActiveRecord::Migration[8.0]
  def change
    create_table :salary_structures do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.string :country_code, limit: 2
      t.text :description
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :salary_structures, :code, unique: true
    add_index :salary_structures, :country_code
  end
end
