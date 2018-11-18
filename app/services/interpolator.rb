class Interpolator
  REGEX = /\{\{\s*([\w+_]+)(?>\s*\|\s*([\w\-\+]+))?\s*\}\}/ix.freeze
  FORMATTERS = {
    datetime: ->(value) { I18n.l(value, format: :short) }
  }.freeze
  CLASS_MAPPING = {
    Booking => BookingSerializer,
    Message => MessageSerializer,
    Invoice => InvoiceSerializer,
    Contract => ContractSerializer
  }.freeze

  attr_reader :subject, :serializer

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

  def to_h
    @serializer&.serializable_hash || {}
  end

  def interpolate_string(original_string)
    original_string.dup.gsub(REGEX) do |match|
      formatters = match.delete('{ }').split('|')
      placeholder = formatters.shift
      value = to_h.fetch(placeholder, '')
      formatters.inject(value) do |memo, formatter|
        formatter = @formatters[formatter.to_sym]
        (formatter.respond_to?(:call) && formatter.call(memo)) || memo
      end
    end
  end
end
