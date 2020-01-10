module PaymentInfos
  class TextPaymentInfo < ::PaymentInfo
    delegate :esr_participant_nr, to: :organisation

    def to_h
      super.merge(esr_participant_nr: esr_participant_nr)
    end
  end
end
