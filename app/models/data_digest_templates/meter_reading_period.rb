# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digest_templates
#
#  id               :bigint           not null, primary key
#  columns_config   :jsonb
#  group            :string
#  label            :string
#  prefilter_params :jsonb
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_data_digest_templates_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

module DataDigestTemplates
  class MeterReadingPeriod < Tabular
    ::DataDigestTemplate.register_subtype self
    DEFAULT_COLUMN_CONFIG = [
      {
        header: ::MeterReadingPeriod.human_attribute_name(:id),
        body: '{{ meter_reading_period.id }}'
      },
      {
        header: ::Booking.human_attribute_name(:ref),
        body: '{{ booking.ref }}'
      },
      {
        header: ::MeterReadingPeriod.human_attribute_name(:begins_at),
        body: '{{ booking.begins_at | datetime_format }}'
      },
      {
        header: ::MeterReadingPeriod.human_attribute_name(:ends_at),
        body: '{{ booking.ends_at | datetime_format }}'
      },
      {
        header: ::Tarif.human_attribute_name(:label),
        body: '{{ meter_reading_period.tarif.label }}'
      },
      {
        header: ::MeterReadingPeriod.human_attribute_name(:start_value),
        body: '{{ meter_reading_period.start_value }}'
      },
      {
        header: ::MeterReadingPeriod.human_attribute_name(:end_value),
        body: '{{ meter_reading_period.end_value }}'
      }
    ].freeze

    column_type :default do
      body do |meter_reading_period, template_context_cache|
        booking = meter_reading_period.booking
        context = template_context_cache[cache_key(meter_reading_period)] ||=
          TemplateContext.new(meter_reading_period:, booking:, organisation: meter_reading_period.organisation).to_h
        @templates[:body]&.render!(context)
      end
    end

    def periodfilter(period = nil)
      filter_class.new(begins_at_after: period&.begin, begins_at_before: period&.end)
    end

    def filter_class
      ::MeterReadingPeriod::Filter
    end

    def base_scope
      @base_scope ||= ::MeterReadingPeriod.joins(:tarif).where(tarif: { organisation_id: organisation }).ordered
    end
  end
end
