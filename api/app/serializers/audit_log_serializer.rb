# One audit entry: what changed ({ field => [old, new] }), on which record, by whom.
class AuditLogSerializer
  def self.call(log)
    log.slice(:id, :action, :auditable_type, :auditable_id, :change_set, :created_at).symbolize_keys
       .merge(user: log.user.slice(:id, :name))
  end
end
