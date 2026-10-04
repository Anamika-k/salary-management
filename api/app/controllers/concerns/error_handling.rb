# The ONE place where expected errors become HTTP responses. Each handled error
# is logged as a warning. Unexpected errors are deliberately NOT rescued: they
# become 500s and reach logs/error tracking instead of being swallowed.
# Response shape matches Devise's 401 body: { error:, code:, details: }.
module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound do |error|
      render_error(:not_found, "not_found", error.message)
    end

    rescue_from ActiveRecord::RecordInvalid do |error|
      render_error(:unprocessable_content, "record_invalid", error.message, error.record.errors.to_hash)
    end

    rescue_from ActionController::ParameterMissing do |error|
      render_error(:bad_request, "parameter_missing", error.message)
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
end
