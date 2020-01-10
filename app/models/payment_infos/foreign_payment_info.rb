module PaymentInfos
  class ForeignPaymentInfo < ::PaymentInfo
    delegate :esr_participant_nr, to: :organisation
  end
end
