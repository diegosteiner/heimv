# frozen_string_literal: true

class TemplateContext
  SERIALIZERS = {
    Booking => Manage::BookingSerializer,
    Organisation => Manage::OrganisationSerializer,
    Home => Manage::HomeSerializer,
    Payment => Manage::PaymentSerializer,
    Invoice => Manage::InvoiceSerializer,
    InvoicePart => Manage::InvoicePartSerializer,
    Tenant => Manage::TenantSerializer,
    Usage => Manage::UsageSerializer,
    PaymentInfo => Manage::PaymentInfoSerializer
  }.freeze

  def initialize(context)
    @original_context = context || {}
  end

  def to_h
    @to_h ||= @original_context.transform_values do |value|
      serializer = self.class.serializer_for(value)
      serializer.try(:render_as_hash, value) ||
        value.try(:to_h) || value.try(:to_s) || value.presence
    end.deep_stringify_keys
  end

  def cache_key
    [self.class, @original_context.hash, I18n.locale].join('-')
  end

  def cached(**options)
    Rails.cache.fetch(cache_key, **options) { to_h }
  end

  def self.serializer_for(value)
    value&.class&.ancestors&.each do |ancestor|
      serializer = SERIALIZERS[ancestor]
      return serializer if serializer.present?
    end
    nil
  end
end
