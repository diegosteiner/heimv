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
    def generate_csv_header
      super.tap do |csv|
        tarifs.each do |tarif|
          csv << "#{tarif.label} (#{Usage.human_attribute_name(:used_units)})"
          csv << "#{tarif.label} (#{Usage.human_attribute_name(:price)})"
        end
      end
    end

    def generate_csv_row(booking)
      super.tap do |csv|
        tarifs.each do |tarif|
          booking.usages.of_tarif(tarif).take.tap do |usage|
            csv << usage.used_units
            csv << usage.price
          end
        end
      end
    end
  end
end
