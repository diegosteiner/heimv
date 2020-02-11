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
    end

    def formats
      super + [:pdf]
    end

    def records
      @records ||= filter.reduce(organisation.bookings.ordered)
    end

    protected

    def generate_tabular_header
      [
        ::Booking.human_attribute_name(:ref), ::Home.model_name.human,
        ::Occupancy.human_attribute_name(:begins_at), ::Occupancy.human_attribute_name(:ends_at),
        ::Booking.human_attribute_name(:purpose)
      ]
    end

    def generate_tabular_footer
      []
    end

    def generate_tabular_row(booking)
      booking.instance_eval do
        [
          ref, home.name, I18n.l(occupancy.begins_at, format: :short), I18n.l(occupancy.ends_at, format: :short),
          ::Booking.human_enum(:purpose, purpose)
        ]
      end
    end
  end
end
