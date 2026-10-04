# Append-only record of a sensitive change: who did what to which record, with
# the before/after values ({ "field" => [old, new] }). Never edited or deleted.
class AuditLog < ApplicationRecord
  belongs_to :user
  belongs_to :auditable, polymorphic: true

  enum :action, { created: "created", updated: "updated", deleted: "deleted", restored: "restored" }, validate: true

  validates :change_set, presence: true

  def readonly?
    persisted?
  end
end
