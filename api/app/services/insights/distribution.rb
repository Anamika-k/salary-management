# How a country's salaries are spread: about 8 equal-width bands with round
# boundaries (e.g. 300,000-400,000), each with a headcount. A salary on a
# boundary belongs to the higher band.
module Insights
  class Distribution
    TARGET_BANDS = 8
    NICE_STEPS = [ 1, 2, 2.5, 5, 10 ].freeze

    def initialize(country:)
      @country = PaidSalaries.country!(country)
    end

    def call
      amounts = PaidSalaries.call(country: @country[:code]).order(:annual_salary).pluck(:annual_salary)
      { country: @country, currency: @country[:currency], headcount: amounts.size, bands: bands(amounts) }
    end

    private

    def bands(amounts)
      return [] if amounts.empty?

      step = nice_step((amounts.last - amounts.first) / TARGET_BANDS)
      start = (amounts.first / step).floor * step
      bands = Array.new(((amounts.last - start) / step).floor + 1) do |index|
        { from: start + (index * step), to: start + ((index + 1) * step), count: 0 }
      end
      amounts.each { |amount| bands[((amount - start) / step).floor][:count] += 1 }
      bands
    end

    # The round number (1, 2, 2.5 or 5 times a power of ten) closest to the raw width.
    def nice_step(raw)
      raw = [ raw, 1 ].max
      magnitude = 10**Math.log10(raw).floor
      NICE_STEPS.map { |step| BigDecimal(step.to_s) * magnitude }.min_by { |step| (step - raw).abs }
    end
  end
end
