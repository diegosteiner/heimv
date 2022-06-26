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
  class Booking < ::DataDigest
    ::DataDigest.register_subtype self

    def prefilter
      @prefilter ||= ::Booking::Filter.new(prefilter_params)
    rescue StandardError
      ::Booking::Filter.new
    end

    def scope
      @scope ||= prefilter.apply(organisation.bookings.ordered.with_default_includes)
    end

    protected

    def build_header(_period, **_options)
      build_booking_headers
    end

    def build_booking_headers
      [
        ::Booking.human_attribute_name(:ref), ::Home.model_name.human,
        ::Occupancy.human_attribute_name(:begins_at), ::Occupancy.human_attribute_name(:ends_at),
        ::Booking.human_attribute_name(:purpose_description), ::Occupancy.human_attribute_name(:nights)
      ]
    end

    def build_data(period, **_options)
      filter = ::Booking::Filter.new(begins_at_after: period.begin, begins_at_before: period.end)
      filter.apply(scope).map { |booking| build_data_row(booking) }
    end

    def build_data_row(booking)
      build_booking_columns(booking)
    end

    def build_booking_columns(booking)
      booking.instance_eval do
        [
          ref, home.name,
          I18n.l(occupancy.begins_at, format: :short),
          I18n.l(occupancy.ends_at, format: :short),
          "#{purpose_description} (#{category&.title})", occupancy&.nights
        ]
      end
    end
  end
end
