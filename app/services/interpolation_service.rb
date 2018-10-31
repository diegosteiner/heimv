class InterpolationService
  def self.flatten_hash(hash, prepend_keys = [], joint = '_')
    return { prepend_keys => hash } unless hash.is_a?(Hash)

    hash.inject({}) do |memo, pair|
      memo.merge!(flatten(pair.last, (Array.wrap(prepend_keys) + [pair.first]).join(joint), joint))
    end
  end

  def self.call(subject)
    hash = case subject
           when ::Contract
             Public::ContractSerializer.new(subject)
               .serializable_hash(include: Public::ContractSerializer::DEFAULT_INCLUDES)
           when ::Invoice
             Public::InvoiceSerializer.new(subject)
               .serializable_hash(include: Public::InvoiceSerializer::DEFAULT_INCLUDES)
           when ::Booking
             Public::BookingSerializer.new(subject)
               .serializable_hash(include: Public::BookingSerializer::DEFAULT_INCLUDES)
               .merge({
                 edit_manage_booking_url: Rails.application.routes.url_helpers.edit_manage_booking_url(subject.to_param),
                 edit_public_booking_url: Rails.application.routes.url_helpers.edit_public_booking_url(subject.to_param),
               })
           else
             {}
           end

    hash = flatten(hash)
    hash.default = ''
    hash.symbolize_keys
  end

  def self.interpolate(string, hash)
  end

  class Builder
    def initialize(string, hash, formatters = {})
      @original_string, @hash = string, hash.with_indifferent_access
      @formatters = formatters.reverse_merge({
        datetime: -> (value) { I18n.l(value, format: :short) }
      }).with_indifferent_access
    end

    def interpolate
      string = @original_string.dup
        string.gsub(/(\{\{\s*([\w+_]+)(?>\s*\|\s*([\w\-\+]+))?\s*\}\})/ix) do |match|
          formatters = match.delete('{ }').split('|')
          placeholder = formatters.shift
          value = @hash.fetch(placeholder, '')
          formatters.inject(value) do |memo, formatter|
            formatter = @formatters[formatter]
            next memo unless formatter.respond_to?(:call)
            formatter.call(memo)
          end
        end
    end
  end
end
