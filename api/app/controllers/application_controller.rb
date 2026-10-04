# Base for all API controllers. Every endpoint requires a signed-in HR user
# unless a controller explicitly skips it (only sign-in does). Expected errors
# are rendered by ErrorHandling; actions never rescue.
class ApplicationController < ActionController::API
  include ErrorHandling

  before_action :authenticate_user!
end
