# == Schema Information
#
# Table name: bookings
#
#  id                    :uuid             not null, primary key
#  approximate_headcount :integer
#  cancellation_reason   :text
#  committed_request     :boolean
#  editable              :boolean          default(TRUE)
#  email                 :string
#  import_data           :jsonb
#  internal_remarks      :text
#  invoice_address       :text
#  messages_enabled      :boolean          default(FALSE)
#  purpose               :string
#  ref                   :string
#  remarks               :text
#  state                 :string           default("initial"), not null
#  state_data            :json
#  tenant_organisation   :string
#  usages_entered        :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  home_id               :bigint           not null
#  organisation_id       :bigint           not null
#  tenant_id             :integer
#
# Indexes
#
#  index_bookings_on_home_id          (home_id)
#  index_bookings_on_organisation_id  (organisation_id)
#  index_bookings_on_ref              (ref)
#  index_bookings_on_state            (state)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

module DataDigests
  class Tarif < DataDigests::Booking
    def tarif_ids=(tarif_ids)
      data_digest_params['tarif_ids'] = tarif_ids.reject(&:blank?)
    end

    def tarif_ids
      data_digest_params.fetch('tarif_ids', [])
    end

    def tarifs
      ::Tarif.where(id: tarif_ids)
    end

    protected

    def generate_tabular_header
      super + tarifs.flat_map do |tarif|
        [
          "#{tarif.label} (#{::Usage.human_attribute_name(:used_units)})",
          "#{tarif.label} (#{::Usage.human_attribute_name(:price)})"
        ]
      end
    end

    def generate_tabular_row(booking)
      helper = ActiveSupport::NumberHelper
      super + tarifs.flat_map do |tarif|
        usage = booking.usages.of_tarif(tarif).take
        next ['', ''] unless usage

        [
          helper.number_to_rounded(usage.used_units || 0, precision: 2, strip_insignificant_zeros: true),
          helper.number_to_currency(usage.price || 0, unit: '')
        ]
      end
    end
  end
end
