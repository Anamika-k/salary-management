# Allows the React app (served from a different origin) to call this API.
# Authorization is exposed so the browser can read the JWT issued on sign-in.
# FRONTEND_ORIGINS is a comma-separated list, e.g. "https://hr.acme.com".
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*ENV.fetch("FRONTEND_ORIGINS", "http://localhost:5173").split(","))

    resource "/api/*",
             headers: :any,
             methods: %i[get post put patch delete options head],
             expose: [ "Authorization" ]
  end
end
