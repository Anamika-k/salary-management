# Counts the SQL queries a block runs, so specs can prove list endpoints have
# no N+1 problem (query count stays flat as the number of records grows).
module QueryCounter
  def count_queries(&block)
    count = 0
    counter = ->(*, payload) { count += 1 unless payload[:name].in?(%w[SCHEMA TRANSACTION]) }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    count
  end
end

RSpec.configure do |config|
  config.include QueryCounter
end
