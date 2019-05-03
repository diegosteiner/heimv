module BookingReports
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
      super.tap do |csv|
        tarifs.each do |tarif|
          csv << "#{tarif.label} (#{Usage.human_attribute_name(:used_units)})"
          csv << "#{tarif.label} (#{Usage.human_attribute_name(:price)})"
        end
      end
    end

    def generate_tabular_row(booking)
      super.tap do |csv|
        tarifs.each do |tarif|
          booking.usages.of_tarif(tarif).take.tap do |usage|
            csv << ActiveSupport::NumberHelper.number_to_rounded(usage&.used_units || 0, precision: 2)
            csv << ActiveSupport::NumberHelper.number_to_currency(usage&.price || 0, unit: '')
          end
        end
      end
    end
  end
end
