class InterpolationContext
  CLASS_MAPPING = {
    Booking => Public::BookingSerializer,
    Invoice => Public::InvoiceSerializer,
    Contract => Public::ContractSerializer
  }.freeze

  delegate :[], :to_h, :keys, to: :@context

  def initialize(*context)
    @context = {}
    context.each { |object| register(object) }
  end

  def register(object, key: object.class.to_s.downcase)
    @context[key.to_s] = CLASS_MAPPING[object.class]&.new(object)&.serializable_hash.deep_stringify_keys
  end

  def self.[](*context)
    new(*context)
  end
end
