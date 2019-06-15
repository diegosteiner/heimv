module Import
  class CSVFromStGeorg
      HEADER_MATCHER = {
        bookings: %r{\A.Belegungsnummer;VermieterNummer;Gruppenname},
        tenants:  %r{\ABelegungsnummer;Kundennummer;MieterName},
        booking_tenants: %r{\AT_.+Belegungen}
  }.freeze
      PURPOSE_MATCHER = {
        'lager' => :camp,
        'xxx' => :event
      }.freeze
      MONTH_REGEX = /Januar|Februar|März|April|Mai|Juni|Juli|August|September|Oktober|November|Dezember/.freeze
      MONTH_REPLACEMENTS = {
        'Januar' => 1,
        'Februar' => 2,
        'März' => 3,
        'April' => 4,
        'Mai' => 5,
        'Juni' => 6,
        'Juli' => 7,
        'August' => 8,
        'September' => 9,
        'Oktober' => 10,
        'November' => 11,
        'Dezember' => 12
      }.freeze

    def initialize(files = nil, result = Import::Result)
      @files = triage_by_headers(files || Dir[Rails.root.join('tmp', 'import', '*')])
      puts @files
      # ::CSV.foreach(file, options) do |row|
      #   result << process_row(row, result)
      #   # return result
      # end
    end

    def triage_by_headers(files)
      headers = files.map { |file| [File.open(file, &:readline), file] }.to_h
      HEADER_MATCHER.dup.transform_values do |matcher|
        headers[headers.keys.find { |header| header =~ matcher }]
      end
    end

    def self.csv_options
      { headers: true, converters: :all, header_converters: :symbol, col_sep: ';' }
    end

      protected

      def process_tenant_row(row)
      end

      def process_booking_csv(csv)
        csv.map do |row|
          next if row[:belegungsnummer].blank?

          create_booking(row, extract_tenant(row, result)).tap do |booking|
            create_transitions(row, booking)
            create_invoices(row, booking)
            create_payments(row, booking)
          end
        end
      end

      def create_booking(row, tenant)
        Booking.create(
          ref: row[:belegungsnummer], tenant_organisation: row[:gruppenname], remarks: row[:bemerkungen], occupancy: extract_occupancy(row), tenant: tenant, email: tenant.email, home: extract_home(row), approximate_headcount: extract_approximate_headcount(row), purpose: extract_purpose(row),
          committed_request: true, invoice_address: extract_invoice_address(row), import_data: row.to_h,
          transition_to: :definitive_request, messages_enabled: false
        )
      end

      def create_payments(row, booking); end

      def create_invoices(row, booking); end

      def create_transitions(_row, booking)
        booking.state_machine.transition_to(:confirmed) && booking.state_machine.transition_to(:upcoming)
      end

      def extract_approximate_headcount(row)
        row.fetch(:anzahlkinder, 0) + row.fetch(:anzahljugendliche) + row.fetch(:anzahlerwachsene)
      end

      def extract_home(row)
        Home.find_by(Home.arel_table[:ref].matches(row[:belegungsnummer][0] + '%'))
      end

      def extract_purpose(row)
        PURPOSE_MATCHER.fetch(row[:zweck], nil)
      end

      def extract_tenant(_row)
        Tenant.all.first
        # Tenant.where("import_data->'kundennummer' = ?", row[:kundennummer]).take || Tenant.new
      end

      def extract_occupancy(row)
        Occupancy.new(
          occupancy_type: :occupied,
          begins_at: extract_date("#{row[:ankunftsdatum]} #{row[:ankunftszeit]}"),
          ends_at: extract_date("#{row[:abreisedatum]} #{row[:abreisezeit]}")
        )
      end

      def extract_invoice_address(row)
        return if row[:rechnungan]

        `#{row[:rechnungvorname]} #{row[:rechnungname]}
         #{row[:rechnungadresse]}
         #{row[:rechnungplz]} #{row[:rechnungort]} #{row[:rechnungland]}`
      end

      def extract_date(date)
        Time.zone.strptime(date.split(', ').last.gsub(MONTH_REGEX, MONTH_REPLACEMENTS), '%d. %m %Y %H:%M')
      rescue ArgumentError
        nil
      end
  end
end
