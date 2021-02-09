# frozen_string_literal: true

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

    delegate :esr_beneficiary_account, to: :organisation
  end
end
