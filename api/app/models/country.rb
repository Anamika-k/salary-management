# The countries ACME employs people in, each with its pay currency.
# A fixed list in code (not a table) because it changes rarely and needs no UI;
# the currency becomes the default currency for an employee's salary.
class Country
  ALL = {
    "IN" => { name: "India", currency: "INR" },
    "US" => { name: "United States", currency: "USD" },
    "GB" => { name: "United Kingdom", currency: "GBP" },
    "DE" => { name: "Germany", currency: "EUR" },
    "SG" => { name: "Singapore", currency: "SGD" },
    "AE" => { name: "United Arab Emirates", currency: "AED" }
  }.freeze

  def self.codes
    ALL.keys
  end

  def self.find(code)
    details = ALL[code]
    details && { code:, **details }
  end

  def self.all
    codes.map { |code| find(code) }
  end
end
