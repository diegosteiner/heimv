# frozen_string_literal: true

module RefBuilders
  class InvoiceAccounting < RefBuilder
    DEFAULT_TEMPLATE = '%<short_year>2d%<sequence_number>04d'

    def initialize(invoice)
      super(invoice.organisation)
      @invoice = invoice
    end

    def generate(template_string = @organisation.invoice_accounting_ref_template)
      generate_lazy(template_string)
    end

    ref_part home_id: proc { @invoice.booking.home_id },
             tenant_id: proc { @invoice.booking.tenant_id },
             sequence_number: proc { @invoice.sequence_number },
             sequence_year: proc { @invoice.sequence_year },
             short_year: proc { @invoice.sequence_year - 2000 }
  end
end
