# Writes an audit entry for a record that was just saved: who changed it, the
# action, and the changed fields as { "field" => [old, new] }. Shared by every
# service that changes sensitive data, so the trail looks the same everywhere.
module Audit
  class Logger
    IGNORED_FIELDS = %w[id created_at updated_at].freeze

    def initialize(user)
      @user = user
    end

    def record(auditable, action)
      AuditLog.create!(user: @user, auditable:, action:,
                       change_set: auditable.saved_changes.except(*IGNORED_FIELDS).as_json)
    end
  end
end
