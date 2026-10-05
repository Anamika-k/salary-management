# Raised when an insights request names a country ACME doesn't employ people in.
module Insights
  class UnknownCountryError < ApplicationError
    def status
      :bad_request
    end
  end
end
