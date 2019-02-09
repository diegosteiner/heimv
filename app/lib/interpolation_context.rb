class InterpolationContext
  CLASS_MAPPING = {
    Booking => Manage::BookingSerializer,
    Invoice => Manage::InvoiceSerializer,
    Contract => Manage::ContractSerializer
  }.freeze

  delegate :[], :keys, to: :@context

  def initialize(*context)
    @context = {}
    context.each { |object| register(object) }
  end

  def to_liquid
    @context.to_h.deep_stringify_keys
  end

  def register(object, key: object.class.to_s.downcase)
    @context[key.to_s] = CLASS_MAPPING[object.class]&.new(object)&.serializable_hash
  end

  def self.[](*context)
    new(*context)
  end
end
