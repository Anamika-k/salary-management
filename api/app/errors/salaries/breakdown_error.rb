# Raised when a salary can't be broken down: the amount isn't a positive number,
# or the structure's rules produce impossible figures (earnings above gross,
# earnings not adding up to gross, deductions above gross).
module Salaries
  class BreakdownError < ApplicationError
  end
end
