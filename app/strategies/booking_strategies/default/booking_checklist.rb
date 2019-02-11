module BookingStrategies
  class Default
    class BookingChecklist < BookingStrategy::BookingChecklist
      state :confirmed do |_booking|
        [
          ChecklistItem.new(:deposit_paid, nil, true),
          ChecklistItem.new(:contract_signed, nil, true)
        ]
      end
    end
  end
end
