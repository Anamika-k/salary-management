# Builds request headers carrying a valid JWT for the given user, so request
# specs can hit protected endpoints without going through sign-in each time.
require "devise/jwt/test_helpers"

module AuthHelpers
  def auth_headers_for(user)
    Devise::JWT::TestHelpers.auth_headers({ "Accept" => "application/json" }, user)
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end
