module RefStrategies
  class ESR < RefStrategy
    # ESR Modes
    # 01 = ESR in CHF
    # 04 = ESR+ in CHF
    # 11 = ESR in CHF zur Gutschrift auf das eigene Konto
    # 14 = ESR+ in CHF zur Gutschrift auf das eigene Konto
    # 21 = ESR in EUR
    # 23 = ESR in EUR zur Gutschrift auf das eigene Konto
    # 31 = ESR+ in EUR
    # 33 = ESR+ in EUR zur Gutschrift auf das eigene Konto
    def generate(invoice)
      with_checksum format('%<home_id>03d%<tenant_id>06d%<invoice_id>07d', home_id: invoice.booking.home.id,
                                                                           tenant_id: invoice.booking.tenant.id,
                                                                           invoice_id: invoice.id)
    end

    def checksum(ref)
      check_table = [0, 9, 4, 6, 8, 2, 7, 1, 3, 5]
      (10 - ref.to_s.scan(/\d/).inject(0) { |carry, digit| check_table[(digit.to_i + carry) % check_table.size] }) % 10
    end

    def with_checksum(ref)
      ref.to_s + checksum(ref).to_s
    end

    def format_ref(ref)
      return '' if ref.blank?

      ref.reverse.chars.in_groups_of(5).reverse.map { |group| group.reverse.join }.join(' ')
    end

    def code_line(invoice, esr_mode: '01')
      code = {
        esr_mode: esr_mode,
        amount_in_cents: invoice.amount_in_cents,
        checksum_1: checksum(esr_mode + format('%<amount_in_cents>010d', amount_in_cents: invoice.amount_in_cents)),
        ref: invoice.ref.to_s.rjust(27, '0'),
        account_nr: account_nr_to_code(invoice.organisation.esr_participant_nr)
      }
      format('%<esr_mode>s%<amount_in_cents>010d%<checksum_1>d>%<ref>s+ %<account_nr>s>', code)
    end

    def find_invoice_by_ref(ref, scope: Invoice)
      ref = ref.delete(' ').ljust(27)
      ref_column = Invoice.arel_table[:ref]
      padded_ref_column = Arel::Nodes::NamedFunction.new('LPAD', [ref_column, 27, Arel::Nodes.build_quoted('0')])
      scope.where(padded_ref_column.eq(ref)).first
    end

    def account_nr_to_code(value)
      parts = value.match(/(?<esr_mode>\d{2})-(?<id>\d{3,6})-(?<checksum>\d)/)&.named_captures || {}
      parts.transform_keys!(&:to_sym).transform_values!(&:to_i)
      return '' if parts.none?

      format('%<esr_mode>02d%<id>06d%<checksum>1d', parts)
    end
  end
end
