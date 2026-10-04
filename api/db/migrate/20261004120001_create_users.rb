# HR Managers who sign in. Kept separate from employees: the people managing
# salaries and the people being paid are different things.
# Columns match Devise (database_authenticatable) + devise-jwt (jti matcher).
class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :encrypted_password, null: false, default: ""
      t.string :jti, null: false # regenerated on sign-out to revoke JWTs
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :jti, unique: true
  end
end
