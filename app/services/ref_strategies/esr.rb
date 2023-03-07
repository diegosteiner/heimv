# frozen_string_literal: true

module RefStrategies
  class ESR
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
      with_checksum format('%<prefix>s%<home_id>03d%<tenant_id>06d%<invoice_id>07d',
                           prefix: digits(invoice.organisation.esr_ref_prefix).join,
                           home_id: invoice.booking.home_id,
                           tenant_id: invoice.booking.tenant.id,
                           invoice_id: invoice.id)
    end

    def digits(string)
      string.to_s.scan(/\d/) || []
    end

    def checksum(ref)
      check_table = [0, 9, 4, 6, 8, 2, 7, 1, 3, 5]
      (10 - digits(ref).inject(0) { |carry, digit| check_table[(digit.to_i + carry) % check_table.size] }) % 10
    end

    def with_checksum(ref)
      "#{ref}#{checksum(ref)}"
    end

    def format_ref(ref)
      return '' if ref.blank?

      ref.reverse.chars.in_groups_of(5).reverse.map { |group| group.reverse.join }.join(' ')
    end

    def find_invoice_by_ref(ref, scope:)
      ref_column = Invoice.arel_table[:ref]
      padded_ref_column = Arel::Nodes::NamedFunction.new('LPAD', [ref_column, 27, Arel::Nodes.build_quoted('0')])
      scope.where(padded_ref_column.eq(normalize_ref(ref))).first
    end

    def normalize_ref(ref)
      ref = ref.delete(' ')
      qr_ref = ref.match(/\ARF\d{2}(?<ref>\d+)\z/)
      ref = qr_ref[:ref] if qr_ref
      ref.rjust(27, '0')
    end

    def account_nr_to_code(value)
      parts = value&.match(/(?<esr_mode>\d{2})-(?<id>\d{3,6})-(?<checksum>\d)/)&.named_captures || {}
      parts.transform_keys!(&:to_sym).transform_values!(&:to_i)
      return '' if parts.none?

      format('%<esr_mode>02d%<id>06d%<checksum>1d', parts)
    end
  end
end
