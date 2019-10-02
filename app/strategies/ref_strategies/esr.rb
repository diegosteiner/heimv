module RefStrategies
  class ESR < RefStrategy
    def generate(invoice)
      ref = format('%<home_id>03d%<tenant_id>06d%<invoice_id>012d', home_id: invoice.booking.home.id,
                                                                    tenant_id: invoice.booking.tenant.id,
                                                                    invoice_id: invoice.id)
      ref + checksum(ref).to_s
    end

    def checksum(ref)
      check_table = [0, 9, 4, 6, 8, 2, 7, 1, 3, 5]
      10 - ref.to_s.scan(/\d/).inject(0) { |carry, digit| check_table[(digit.to_i + carry) % check_table.size] }
    end

    def format_ref(ref)
      return '' if ref.blank?

      ref.reverse.chars.in_groups_of(5).reverse.map { |group| group.reverse.join }.join(' ')
    end
  end
end
