module PaymentInfos
  class OrangePaymentSlip < PaymentInfo
    # 01 = ESR in CHF
    # 04 = ESR+ in CHF
    # 11 = ESR in CHF zur Gutschrift auf das eigene Konto
    # 14 = ESR+ in CHF zur Gutschrift auf das eigene Konto
    # 21 = ESR in EUR
    # 23 = ESR in EUR zur Gutschrift auf das eigene Konto
    # 31 = ESR+ in EUR
    # 33 = ESR+ in EUR zur Gutschrift auf das eigene Konto
    ESR_MODE = '01'.freeze

    def code_line
      code = {
        esr_mode: ESR_MODE,
        amount: amount * 100,
        checksum_1: invoice_ref_strategy.checksum(ESR_MODE + format('%<amount>010d', amount: amount * 100)),
        ref: ref,
        account_code: esr_participant_nr.to_code
      }
      format('%<esr_mode>s%<amount>010d%<checksum_1>d>%<ref>s+ %<account_code>s>', code)
    end

    def amount_before_point
      amount.truncate
    end

    def amount_after_point
      ((amount * 100) - (amount.truncate * 100)).to_i
    end

    def esr_participant_nr
      AccountNr.new(organisation.esr_participant_nr)
    end

    def qrcode
      @qrcode ||= SwissQrCode.new(invoice)
      @qrcode.qrcode
    end
  end
end
