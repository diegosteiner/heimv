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
  class Tenant < DataDigests::Booking
    protected

    def build_header(_period, **options)
      super + [
        ::Tenant.model_name.human, '', '', ::Occupancy.human_attribute_name(:nights)
      ]
    end

    def build_data_row(booking)
      super + booking.instance_eval do
        [
          tenant&.address_lines&.join("\n"), tenant&.email, tenant&.phone, occupancy&.nights
        ]
      end
    end
  end
end
