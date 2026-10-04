# Base for all API controllers. Every endpoint requires a signed-in HR user
# unless a controller explicitly skips it (only sign-in does).
class ApplicationController < ActionController::API
  before_action :authenticate_user!
end
