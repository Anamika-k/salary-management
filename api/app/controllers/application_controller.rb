# Base for all API controllers. Every endpoint requires a signed-in HR user
# unless a controller explicitly skips it (only sign-in does). Expected errors
# are rendered by ErrorHandling; actions never rescue. Data is rendered only
# through Rendering (render_records / render_record).
class ApplicationController < ActionController::API
  include ErrorHandling
  include Rendering

  before_action :authenticate_user!
end
