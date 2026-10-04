# Append-only trail of sensitive actions (salary changes, terminations,
# structure edits). Never updated or deleted, so there is no updated_at.
class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action, null: false
      t.references :auditable, polymorphic: true, null: false
      t.json :change_set, null: false
      t.datetime :created_at, null: false

      t.check_constraint "action IN ('created', 'updated', 'deleted', 'restored')",
                         name: "audit_logs_action_check"
    end

    add_index :audit_logs, :created_at
  end
end
