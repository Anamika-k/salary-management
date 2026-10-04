# The only way controllers render data, so every response has the same shape:
# lists are { data: [...], meta: {...} } and always paginated; single records
# are { data: {...} }. Page size defaults to 25 and is capped at 100.
module Rendering
  DEFAULT_PER_PAGE = 25
  MAX_PER_PAGE = 100

  private

  def render_records(records, serializer:)
    page = records.page(requested_page).per(requested_per_page)
    render json: {
      data: page.map { |record| serializer.call(record) },
      meta: { current_page: page.current_page, total_pages: page.total_pages,
              total_count: page.total_count, per_page: page.limit_value }
    }
  end

  def render_record(record, serializer:, status: :ok)
    render json: { data: serializer.call(record) }, status:
  end

  def requested_page
    [ params[:page].to_i, 1 ].max
  end

  def requested_per_page
    per_page = params[:per_page].to_i
    per_page.positive? ? [ per_page, MAX_PER_PAGE ].min : DEFAULT_PER_PAGE
  end
end
