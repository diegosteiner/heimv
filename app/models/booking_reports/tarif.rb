module BookingReports
  class Tarif < BookingReport
    def tarif_ids=(tarif_ids)
      report_params['tarif_ids'] = tarif_ids
    end

    def tarif_ids
      report_params.fetch('tarif_ids', [])
    end

    def tarifs
      Tarif.where(id: tarif_ids)
    end

  protected
    def generate_csv_header
      super + []
    end

    def generate_csv_row(booking)
      super + []
    end
  end
end
