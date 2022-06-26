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
  class Tax < DataDigests::Tarif
    ::DataDigest.register_subtype self

    def build_header(_period, **_options)
      build_booking_headers +
        [
          ::Tenant.model_name.human, ::Tenant.human_attribute_name(:address), ::Tenant.human_attribute_name(:birth_date)
        ] +
        build_tarif_headers
    end

    def build_data_row(booking)
      build_booking_columns(booking) +
        booking.tenant&.instance_eval do
          [full_name, full_address_lines&.join("\n"), birth_date && I18n.l(birth_date)]
        end +
        build_tarif_columns(booking)
    end
  end
end
