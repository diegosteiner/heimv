# frozen_string_literal: true

module RefBuilders
  class InvoicePayment < RefBuilder
    DEFAULT_TEMPLATE = '%<prefix>s%<tenant_sequence_number>06d%<sequence_year>04d%<sequence_number>05d'

    def initialize(invoice)
      super(invoice.organisation)
      @invoice = invoice
    end

    def generate(template_string = @organisation.invoice_payment_ref_template)
      generate_lazy(template_string)
    end

    # TODO: remove ids
    ref_part home_id: proc { @invoice.booking.home_id },
             tenant_id: proc { @invoice.booking.tenant.id },
             tenant_sequence_number: proc { @invoice.booking.tenant.sequence_number },
             sequence_number: proc { @invoice.sequence_number },
             sequence_year: proc { @invoice.sequence_year },
             short_sequence_year: proc { @invoice.sequence_year - 2000 },
             prefix: proc { self.class.digits(@invoice.organisation.esr_ref_prefix.to_s).join }

    def self.digits(ref)
      ref.to_s.scan(/\d/) || []
    end

    def self.with_checksum(ref)
      "#{ref}#{checksum(ref)}"
    end

    def self.checksum(ref)
      check_table = [0, 9, 4, 6, 8, 2, 7, 1, 3, 5]
      (10 - digits(ref).reduce(0) { |carry, digit| check_table[(digit.to_i + carry) % check_table.size] }) % 10
    end
  end
end
