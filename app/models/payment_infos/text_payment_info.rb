module PaymentInfos
  class TextPaymentInfo < ::PaymentInfo
    delegate :esr_participant_nr, to: :organisation
  end
end
