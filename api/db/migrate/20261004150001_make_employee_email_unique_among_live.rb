# Lets a soft-deleted employee's email be reused (a record created by mistake
# is deleted and entered again). MySQL has no partial indexes, so a stored
# generated column holds the email only for live rows and carries the unique index.
class MakeEmployeeEmailUniqueAmongLive < ActiveRecord::Migration[8.1]
  def change
    add_column :employees, :live_email, :virtual, type: :string, stored: true,
                                                  as: "IF(deleted_at IS NULL, email, NULL)"
    remove_index :employees, :email, unique: true
    add_index :employees, :live_email, unique: true
  end
end
