# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                 :bigint           not null, primary key
#  data_digest_params :jsonb
#  filter_params      :jsonb
#  label              :string
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
    def filter
      @filter ||= ::Booking::Filter.new(filter_params)
    rescue StandardError
      ::Booking::Filter.new
    end

    def scope
      filter.apply(organisation.bookings.ordered)
    end

    class Period < DataDigest::Period
      def filter
        @filter ||= ::Booking::Filter.new(begins_at_after: period_range.begin, begins_at_before: period_range.end)
      end

      def filtered
        @filtered ||= filter.apply(@data_digest.scope)
      end

      def data_header
        [
          ::Booking.human_attribute_name(:ref), ::Home.model_name.human,
          ::Occupancy.human_attribute_name(:begins_at), ::Occupancy.human_attribute_name(:ends_at),
          ::Booking.human_attribute_name(:purpose)
        ]
      end

      def data_footer
        []
      end

      def data_row(booking)
        booking.instance_eval do
          [
            ref, home.name, I18n.l(occupancy.begins_at, format: :short), I18n.l(occupancy.ends_at, format: :short),
            purpose
          ]
        end
      end
    end
  end
end
