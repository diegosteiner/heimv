class Interpolator
  REGEX = /\{\{\s*([\w+_]+)(?>\s*\|\s*([\w\-\+]+))?\s*\}\}/ix
  FORMATTERS = {
    datetime: -> (value) { I18n.l(value, format: :short) }
  }.with_indifferent_access.freeze
  CLASS_MAPPING = {
    Booking => BookingSerializer,
    # Message => MessageInterpolator,
    Invoice => InvoiceSerializer,
    Contract => ContractSerializer
  }.freeze

  attr_reader :subject

  def initialize(subject, formatters = {})
    @subject = subject
    @formatters = formatters.reverse_merge(FORMATTERS)
    @serializer = CLASS_MAPPING[subject.class]&.new(subject)
  end

  def interpolate(string_or_markdown)
    if string_or_markdown.is_a?(Markdown)
      Markdown.new(interpolate_string(string_or_markdown.to_s))
    else
      interpolate_string(string_or_markdown.to_s)
    end
  end

  def interpolate_string(original_string)
    original_string.dup.gsub(REGEX) do |match|
      formatters = match.delete('{ }').split('|')
      placeholder = formatters.shift
      value = (@serializer&.serializable_hash || {}).fetch(placeholder, '')
      formatters.inject(value) do |memo, formatter|
        formatter = @formatters[formatter]
        (formatter.respond_to?(:call) && formatter.call(memo)) || memo
      end
    end
  end
end
