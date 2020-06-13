module PaymentInfos
  class OrangePaymentSlip < ::PaymentInfo
    def code_line
      invoice_ref_strategy.code_line(invoice)
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
