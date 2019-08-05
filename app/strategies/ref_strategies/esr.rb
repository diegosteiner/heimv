module RefStrategies
  class ESR < RefStrategy
    def generate(invoice)
      ref = format('%03d%06d%012d', invoice.booking.home.id, invoice.booking.tenant.id, invoice.id)
      ref + checksum(ref).to_s
    end

    def checksum(ref)
      check_table = [0, 9, 4, 6, 8, 2, 7, 1, 3, 5]
      10 - ref.to_s.scan(/\d/).inject(0) { |carry, digit| check_table[(digit.to_i + carry) % check_table.size] }
    end

    def format_ref(ref)
      ref.reverse.chars.in_groups_of(5).reverse.map { |group| group.reverse.join }.join(' ')
    end
  end
end
