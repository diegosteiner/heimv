# frozen_string_literal: true

module PaymentInfos
  TYPES = {
    qr_bill: QrBill,
    orange_payment_slip: OrangePaymentSlip,
    text_payment_info: TextPaymentInfo,
    foreign_payment_info: ForeignPaymentInfo
  }.freeze
end
