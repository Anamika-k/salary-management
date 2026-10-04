# Soft delete for business records: rows are marked with deleted_at instead of
# being removed, so history and audit trails stay intact.
# Deliberately no default_scope: queries opt in with `.kept` so nothing is hidden by surprise.
module SoftDeletable
  extend ActiveSupport::Concern

  included do
    scope :kept, -> { where(deleted_at: nil) }
    scope :deleted, -> { where.not(deleted_at: nil) }
  end

  def deleted?
    deleted_at.present?
  end

  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def restore!
    update!(deleted_at: nil)
  end
end
