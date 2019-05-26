# == Schema Information
#
# Table name: reports
#
#  id            :bigint           not null, primary key
#  type          :string
#  label         :string
#  filter_params :jsonb
#  report_params :jsonb
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

module Reports
  class Tarif < BookingReport
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
      super + tarifs.flat_map do |tarif|
        [
          "#{tarif.label} (#{Usage.human_attribute_name(:used_units)})",
          "#{tarif.label} (#{Usage.human_attribute_name(:price)})"
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
