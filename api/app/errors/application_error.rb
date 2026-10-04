# Base class for every domain error raised by our services (e.g. an overlapping
# salary period). Subclasses override #status when 422 isn't right; the API
# renders them through ErrorHandling, so services never rescue or render.
class ApplicationError < StandardError
  attr_reader :details

  def initialize(message = nil, details: {})
    super(message)
    @details = details
  end

  def status
    :unprocessable_content
  end

  def code
    self.class.name.demodulize.underscore
  end
end
