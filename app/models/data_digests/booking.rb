# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digests
#
#  id                 :bigint           not null, primary key
#  columns            :jsonb
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
    DEFAULT_COLUMN_CONFIG = [
      {
        header: ::Booking.human_attribute_name(:ref),
        body: '{{ booking.ref }}'
      },
      {
        header: ::Home.model_name.human,
        body: '{{ booking.home.name }}'
      },
      {
        header: ::Occupancy.human_attribute_name(:begins_at),
        body: '{{ booking.occupancy.begins_at | datetime_format }}'
      },
      {
        header: ::Occupancy.human_attribute_name(:ends_at),
        body: '{{ booking.occupancy.ends_at | datetime_format }}'
      },
      {
        header: ::Booking.human_attribute_name(:purpose_description),
        body: "{{ booking.purpose_description }}\n{{ booking.category.title }}"
      },
      {
        header: ::Occupancy.human_attribute_name(:nights),
        body: '{{ booking.occupancy.nights }}'
      }
    ].freeze

    ::DataDigest.register_subtype self

    column_type :default do
      body do |booking|
        @templates[:body]&.render!('booking' => booking)
      end
    end

    def filter(period = nil)
      ::Booking::Filter.new(prefilter_params.merge(begins_at_after: period&.begin, begins_at_before: period&.end))
    rescue StandardError
      ::Booking::Filter.new
    end

    def base_scope
      @base_scope ||= organisation.bookings.ordered.with_default_includes
    end
  end
end
