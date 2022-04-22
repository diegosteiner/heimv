# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                 :bigint           not null, primary key
#  data_digest_params :jsonb
#  label              :string
#  prefilter_params   :jsonb
#  type               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organisation_id    :bigint           not null
#
# Indexes
#
#  index_data_digests_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

module DataDigests
  class MeterReadingPeriod < DataDigest
    ::DataDigest.register_subtype self

    def prefilter
      @prefilter ||= ::MeterReadingPeriod::Filter.new(prefilter_params)
    rescue StandardError
      ::MeterReadingPeriod::Filter.new
    end

    def scope
      @scope ||= prefilter.apply(::MeterReadingPeriod.joins(:tarif).where(tarif: { home: organisation.homes }).ordered)
    end

    protected

    def build_data(period, **_options)
      filter = ::MeterReadingPeriod::Filter.new(ends_at_after: period.begin, ends_at_before: period.end)
      filter.apply(scope).map { |meter_reading_period| build_data_row(meter_reading_period) }
    end

    def build_header(_period, **_options)
      [
        ::Tarif.human_attribute_name(:label),
        ::Home.model_name.human,
        ::MeterReadingPeriod.human_attribute_name(:begins_at),
        ::MeterReadingPeriod.human_attribute_name(:ends_at),
        ::MeterReadingPeriod.human_attribute_name(:start_value),
        ::MeterReadingPeriod.human_attribute_name(:end_value),
        ::Booking.human_attribute_name(:ref)
      ]
    end

    def build_data_row(meter_reading_period)
      meter_reading_period.instance_eval do
        [
          tarif.label, tarif.home.name, I18n.l(begins_at, format: :default), I18n.l(ends_at, format: :default),
          start_value, end_value, usage&.booking&.ref
        ]
      end
    end
  end
end
