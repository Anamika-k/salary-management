# The ONE place where errors become HTTP responses; nothing else rescues.
# - Expected errors map to 4xx and are logged as warnings.
# - Unexpected errors (bugs) are logged with backtrace, reported via Rails.error
#   (error tracking subscribes there) and answered with a generic 500, so
#   nothing is swallowed and no internals leak to the client.
# Response shape matches Devise's 401 body: { error:, code:, details: }.
module ErrorHandling
  extend ActiveSupport::Concern

  included do
    # Declared first: Rails checks handlers bottom-up, so this is the fallback.
    rescue_from StandardError, with: :handle_unexpected_error

    rescue_from ActiveRecord::RecordNotFound do |error|
      render_error(:not_found, "not_found", error.message)
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
      render_error(:unprocessable_content, "record_invalid", error.message, error.record.errors.to_hash)
    end

    rescue_from ActionController::ParameterMissing do |error|
      render_error(:bad_request, "parameter_missing", error.message)
    end

    rescue_from Date::Error do |error|
      render_error(:bad_request, "invalid_date", "Invalid date: #{error.message}")
    end

    rescue_from ApplicationError do |error|
      render_error(error.status, error.code, error.message, error.details)
    end
  end

  private

  def render_error(status, code, message, details = {})
    Rails.logger.warn("[#{code}] #{request.method} #{request.path}: #{message}")
    render json: { error: message, code: code, details: details }, status: status
  end

  def handle_unexpected_error(error)
    Rails.logger.error([ "#{error.class}: #{error.message}", *error.backtrace ].join("\n"))
    Rails.error.report(error, handled: false)
    render json: { error: "Something went wrong", code: "internal_server_error", details: {} },
           status: :internal_server_error
  end
end
