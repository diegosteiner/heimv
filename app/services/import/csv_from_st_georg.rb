module Import
  class CSVFromStGeorg
    HEADER_MATCHER = {
      tenants: /\A.?Kundennummer;MieterName;MieterVorname/,
      booking_tenants: /\A.?Belegungsnummer;Kundennummer;MieterName/,
      bookings: /\A.?Belegungsnummer;VermieterNummer;Gruppenname/,
      other: /.*/
    }.freeze

    attr_reader :result, :files

    def initialize(files = nil)
      files = case files
              when String
                files.split(';')
              else
                files
              end
      @files = triage_by_headers(files || Dir[Rails.root.join('tmp', 'import', '*.csv')])
      @result = Import::Result.new
      @tenant_registry = {}
    end

    def process
      ApplicationRecord.transaction do
        Rails.logger.info(files.inspect)
        files.each do |content_type, files_of_type|
          files_of_type.each { |file| process_file(file, content_type) }
        end

        raise ActiveRecord::Rollback unless @result.success?
      end
      @result
    end

    def process_file(file, content_type)
      Rails.logger.info("Processing #{file} as #{content_type}")

      content_type_handlers = {
        tenants: -> { process_tenants_file(file) },
        booking_tenants: -> { process_booking_tenants_file(file) },
        bookings: -> { process_booking_file(file) }
      }
      content_type_handlers[content_type]&.call || Rails.logger.warn("Could not process #{file}")
    end

    def triage_by_headers(files)
      headers = files.map { |file| [file, File.open(file, &:readline)] }.to_h
      HEADER_MATCHER.dup.transform_values do |matcher|
        matching_headers = headers.select { |_file, header| header =~ matcher }
        matching_headers.keys.each { |header| headers.delete(header) }
      end
    end

    def self.csv_options
      { headers: true, converters: :all, header_converters: :symbol, col_sep: ';' }
    end

    def process_booking_tenants_file(file)
      ::CSV.foreach(file, self.class.csv_options) do |row|
        booking_ref = row[:belegungsnummer]
        tenant_old_id = row[:kundennummer]
        tenant = Tenant.where("import_data->>'kundennummer' = ?::text", tenant_old_id).take || Tenant.new

        @tenant_registry[booking_ref] = tenant
      end
    end

    def process_tenants_file(file)
      ::CSV.foreach(file, self.class.csv_options) do |row|
        tenant = TenantRow.new(row).build

        tenant.save
        result << tenant
      end
    end

    def process_booking_file(file)
      ::CSV.foreach(file, self.class.csv_options) do |row|
        next if row[:belegungsnummer].blank?

        booking = BookingRow.new(row, @tenant_registry).build

        if booking.save
          booking.state_machine.transition_to(:confirmed) && booking.state_machine.transition_to(:upcoming)
        end

        result << booking
      end
    end

    class TenantRow
      attr_reader :row

      def initialize(row)
        @row = row
      end

      # rubocop:disable Metrics/AbcSize
      def build
        tenant = Tenant.find_or_initialize_by(email: email)
        tenant.assign_attributes(
          first_name: row[:mietervorname], last_name: row[:mietername],
          street_address: [row[:mieteradresse], row[:mieteradresszusatz]].join("\n"), zipcode: row[:mieterplz],
          city: row[:mieterort], country: country, phone: phone,
          reservations_allowed: true, remarks: row[:mieterbemerkungen], import_data: row.to_h
        )
        tenant
      end
      # rubocop:enable Metrics/AbcSize

      def email
        row[:mieteremail].presence || "mieter+#{legacy_id}@heimv.local"
      end

      def legacy_id
        row[:kundennummer]
      end

      def phone
        [row[:mieterteln], row[:mietertelp], row[:mietertelg]].select(&:present?).join("\n")
      end

      def country
        country = ISO3166::Country.find_by(name: row[:mieterland])
        country.first
      rescue NoMethodError
        'CH'
      end
    end

    class BookingRow
      MONTHS = %w[Januar Februar März April Mai Juni Juli August September Oktober November Dezember].freeze
      MONTH_REPLACEMENTS = MONTHS.map.with_index { |month, i| [month, i + 1] }.to_h.freeze
      MONTH_REPLACEMENT_REGEX = Regexp.new(MONTH_REPLACEMENTS.keys.join('|')).freeze
      PURPOSE_MATCHER = {
        'lager' => :camp,
        'xxx' => :event
      }.freeze
      attr_reader :row

      def initialize(row, tenant_registry = {})
        @row = row
        @tenant_registry = tenant_registry
      end

      def approximate_headcount
        row.fetch(:anzahlkinder, 0) + row.fetch(:anzahljugendliche) + row.fetch(:anzahlerwachsene)
      end

      def home
        Home.find_by(Home.arel_table[:ref].matches(row[:belegungsnummer][0] + '%'))
      end

      def purpose
        PURPOSE_MATCHER.fetch(row[:zweck], nil)
      end

      def occupancy
        Occupancy.new(
          occupancy_type: :occupied,
          begins_at: parse_date("#{row[:ankunftsdatum]} #{row[:ankunftszeit]}"),
          ends_at: parse_date("#{row[:abreisedatum]} #{row[:abreisezeit]}")
        )
      end

      def invoice_address
        return if row[:rechnungan]

        `#{row[:rechnungvorname]} #{row[:rechnungname]}
        #{row[:rechnungadresse]}
        #{row[:rechnungplz]} #{row[:rechnungort]} #{row[:rechnungland]}`
      end

      # rubocop:disable Metrics/AbcSize
      def build
        Booking.find_or_initialize_by(ref: ref) do |booking|
          booking.assign_attributes(
            ref: ref, tenant_organisation: tenant_organisation, remarks: remarks, occupancy: occupancy,
            home: home, approximate_headcount: approximate_headcount, purpose: purpose, tenant: tenant,
            email: tenant&.email, committed_request: true, invoice_address: invoice_address, import_data: row.to_h,
            transition_to: :definitive_request, messages_enabled: false
          )
        end
      end
      # rubocop:enable Metrics/AbcSize

      def remarks
        row[:bemerkungen]
      end

      def tenant
        @tenant_registry.fetch(ref, Tenant.new(email: "mieter+#{ref}@heimv.local"))
      end

      def tenant_organisation
        row[:gruppenname]
      end

      def ref
        row[:belegungsnummer]
      end

      def parse_date(date)
        Time.zone.strptime(date.split(', ').last.gsub(MONTH_REPLACEMENT_REGEX, MONTH_REPLACEMENTS), '%d. %m %Y %H:%M')
      rescue ArgumentError
        nil
      end
    end
  end
end
