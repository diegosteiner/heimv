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
    PaymentInfo => Manage::PaymentInfoSerializer,
    Contract => Manage::ContractSerializer,
    CostEstimation => Manage::CostEstimationSerializer,
    BookingQuestion => Public::BookingQuestionSerializer,
    BookingQuestionResponse => Public::BookingQuestionResponseSerializer,
    MeterReadingPeriod => Manage::MeterReadingPeriodSerializer,
    VatCategory => Public::VatCategorySerializer
  }.freeze

  def initialize(context)
    @original_context = context || {}
  end

  def to_h
    @to_h ||= @original_context.transform_values do |value|
      self.class.serialize_value(value)
    end.merge(Export::Pdf::Renderables::RichText::SUPPORTED_SPECIAL_TOKEN_TAGS.invert).deep_stringify_keys
  end

  def self.serialize_value(value, serializer: serializer_for(value))
    return value.map { serialize_value(_1) } if value.is_a?(Array) || value.is_a?(ActiveRecord::Relation)

    serializer.try(:render_as_hash, value) || value.try(:to_h) || value.try(:to_s) || value.presence
  end

  def self.serializer_for(value)
    value&.class&.ancestors&.each do |ancestor|
      serializer = SERIALIZERS[ancestor]
      return serializer if serializer.present?
    end
    nil
  end
end
