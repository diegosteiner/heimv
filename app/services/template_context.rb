# frozen_string_literal: true

class TemplateContext
  SERIALIZERS = {
    Booking => Manage::BookingSerializer,
    Occupancy => Manage::OccupancySerializer,
    Organisation => Manage::OrganisationSerializer,
    Home => Manage::HomeSerializer,
    Payment => Manage::PaymentSerializer,
    Invoice => Manage::InvoiceSerializer,
    ::Invoice::Item => Manage::InvoiceItemSerializer,
    JournalEntryBatch => Manage::JournalEntryBatchSerializer,
    JournalEntryBatch::Entry => Manage::JournalEntrySerializer,
    Tenant => Manage::TenantSerializer,
    Usage => Manage::UsageSerializer,
    PaymentInfo => Manage::PaymentInfoSerializer,
    Contract => Manage::ContractSerializer,
    CostEstimation => Manage::CostEstimationSerializer,
    BookingQuestion => Public::BookingQuestionSerializer,
    BookingQuestionResponse => Public::BookingQuestionResponseSerializer,
    MeterReadingPeriod => Manage::MeterReadingPeriodSerializer,
    VatCategory => Public::VatCategorySerializer,
    Address => Public::AddressSerializer
  }.freeze

  def initialize(context)
    @context = context || {}
  end

  def to_liquid
    @to_liquid ||= @context.transform_values do |value|
      self.class.serialize_value(value)
    end.merge(Export::Pdf::Renderables::RichText::SUPPORTED_SPECIAL_TOKEN_TAGS.invert).deep_stringify_keys
  end

  def self.serialize_value(value, serializer: nil)
    case value
    when Array, ActiveRecord::Relation
      value.map { serialize_value(it) }
    else
      serializer = serializer_for(value) if serializer.nil?
      serializer&.try(:render_as_hash, value) || value.try(:to_h) || value.try(:to_s) || value.presence
    end
  end

  def self.serializer_for(value)
    value&.class&.ancestors&.each do |ancestor|
      serializer = SERIALIZERS[ancestor]
      return serializer if serializer.present?
    end
    nil
  end
end
