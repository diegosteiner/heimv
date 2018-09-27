class PaymentSlip
  attr_reader :esr_mode

  # 01 = ESR in CHF
  # 04 = ESR+ in CHF
  # 11 = ESR in CHF zur Gutschrift auf das eigene Konto
  # 14 = ESR+ in CHF zur Gutschrift auf das eigene Konto
  # 21 = ESR in EUR
  # 23 = ESR in EUR zur Gutschrift auf das eigene Konto
  # 31 = ESR+ in EUR
  # 33 = ESR+ in EUR zur Gutschrift auf das eigene Konto
  def initialize(invoice, mode = '01')
    @invoice = invoice
    @ref = invoice.ref
    @amount = invoice.amount
    @mode = mode
  end

  def checksums; end

  def checksum(number)
    digits = number.to_s.reverse.scan(/\d/).map(&:to_i)
    digits = digits.each_with_index.map do |d, i|
      d *= 2 if i.even?
      d > 9 ? d - 9 : d
    end
    sum = digits.inject(0) { |m, x| m + x }
    mod = 10 - sum % 10
    mod == 10 ? 0 : mod
  end

  def code
    {
      mode: @mode,
      amount: amount * 100,
      checksum_1: checksum(@mode + format('%010d', amount * 100)),
      ref: @ref,
      checksum_2: checksum(@ref),
      account: account_nr.scan(/\d/).join.to_i
    }
  end

  def code_line
    format('%<mode>s%<amount>010d%<checksum_1>d>%<ref>d%<checksum_2>d+ %<account>08d', code)
  end

  def amount
    @invoice.amount
  end

  def account_nr
    '01-162-8'
  end

  def address
    "Verein Pfadiheime St. Georg\nHeimverwaltung\nChristian Morger\nGeeringstr. 44\n8049 Zürich"
  end

  def esr_ref
    r = @invoice.ref
    format('%02d %05d %05d %05d %05d %05d', r[0..1], r[2..6], r[7..11], r[12..16], r[17..21], checksum(r))
  end
end
