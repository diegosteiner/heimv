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
    EsrService.new.checksum(number)
  end

  def code
    {
      mode: @mode,
      amount: amount * 100,
      checksum_1: checksum(@mode + format('%010d', amount * 100)),
      ref: @ref,
      account: account_nr.scan(/\d/).join.to_i
    }
  end

  def code_line
    format('%<mode>s%<amount>010d%<checksum_1>d>%<ref>s+ %<account>08d', code)
  end

  def amount
    @invoice.amount
  end

  def amount_before_point
    amount.truncate
  end

  def amount_after_point
    amount - amount.truncate
  end

  def account_nr
    '01-162-8'
  end

  def address
    "Verein Pfadiheime St. Georg\nHeimverwaltung\nChristian Morger\nGeeringstr. 44\n8049 Zürich"
  end

  def esr_ref
    @ref.reverse.chars.in_groups_of(5).reverse.map { |group| group.reverse.join }.join(' ')
  end
end
