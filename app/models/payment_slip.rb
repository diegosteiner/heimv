class PaymentSlip
  attr_reader :esr_mode, :invoice

  # 01 = ESR in CHF
  # 04 = ESR+ in CHF
  # 11 = ESR in CHF zur Gutschrift auf das eigene Konto
  # 14 = ESR+ in CHF zur Gutschrift auf das eigene Konto
  # 21 = ESR in EUR
  # 23 = ESR in EUR zur Gutschrift auf das eigene Konto
  # 31 = ESR+ in EUR
  # 33 = ESR+ in EUR zur Gutschrift auf das eigene Konto
  def initialize(invoice, esr_mode = '01')
    @invoice = invoice
    @amount = invoice.amount
    @esr_mode = esr_mode
  end

  def ref_strategy
    @ref_strategy ||= RefStrategies::ESR.new
  end

  def checksums; end

  delegate :checksum, to: :ref_strategy
  delegate :amount, :ref, to: :invoice
  delegate :organisation, :booking, to: :invoice
  delegate :payment_information, to: :organisation

  def invoice_address
    @invoice.booking.invoice_address.presence || @invoice.booking.tenant.address_lines.join("\n")
  end

  def code
    {
      esr_mode: esr_mode,
      amount: amount * 100,
      checksum_1: checksum(esr_mode + format('%<amount>010d', amount: amount * 100)),
      ref: ref,
      account_code: account_nr.to_code
    }
  end

  def code_line
    format('%<esr_mode>s%<amount>010d%<checksum_1>d>%<ref>s+ %<account_code>s>', code)
  end

  def amount_before_point
    amount.truncate
  end

  def amount_after_point
    ((amount * 100) - (amount.truncate * 100)).to_i
  end

  def account_nr
    AccountNr.new(organisation.account_nr)
  end

  def esr_ref
    ref_strategy.format_ref(ref)
  end

  def qrcode
    @qrcode ||= SwissQrCode.new(invoice)
    @qrcode.qrcode
  end
end
