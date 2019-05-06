# == Schema Information
#
# Table name: booking_reports
#
#  id            :bigint           not null, primary key
#  type          :string
#  label         :string
#  filter_params :jsonb
#  report_params :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

module BookingReports
  class Tenant < BookingReport
    def tarif_ids=(tarif_ids)
      report_params['tarif_ids'] = tarif_ids.reject(&:blank?)
    end

    def tarif_ids
      report_params.fetch('tarif_ids', [])
    end

    def tarifs
      ::Tarif.where(id: tarif_ids)
    end

    protected

    def generate_tabular_header
      super + [
        Tenant.model_name.human, Occupancy.human_attribute_name(:nights)
      ]
    end

    def generate_tabular_row(booking)
      super + booking.instance_eval do
        [
          tenant.contact_lines.join("\n"), occupancy.nights
        ]
      end
    end
  end
end
