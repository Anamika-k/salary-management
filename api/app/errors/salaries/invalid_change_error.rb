# Raised when a salary change would break the history rules: starting before
# joining, on or after exit, not after the current salary, or using another
# country's structure.
module Salaries
  class InvalidChangeError < ApplicationError
  end
end
