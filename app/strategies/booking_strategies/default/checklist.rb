module BookingStrategies
  class Default
    class Checklist < BookingStrategy::Checklist
      state :definitive_request do |booking|
        [
          ChecklistItem.new(:tarifs_chosen, booking.booking_copy_tarifs.exists?, [:manage, booking, Tarif]),
          ChecklistItem.new(:contract_created, booking.contract.present?, [:manage, booking, Contract]),
          ChecklistItem.new(:deposit_created, booking.invoices.deposit.exists?, [:manage, booking, Invoice])
        ]
      end

      state :confirmed do |booking|
        [
          ChecklistItem.new(:deposit_paid, booking.invoices.deposit.all?(:paid), [:manage, booking, Invoice]),
          ChecklistItem.new(:contract_signed, booking.contracts.signed.exists?, [:manage, booking, Contract])
        ]
      end

      state :overdue do |booking|
        [
          ChecklistItem.new(:deposit_paid, booking.invoices.deposit.all?(:paid), [:manage, booking, Invoice]),
          ChecklistItem.new(:contract_signed, booking.contracts.signed.exists?, [:manage, booking, Contract])
        ]
      end

      state :past do |booking|
        [
          ChecklistItem.new(:usages_created, booking.usages.amount.any?(&:used?), [:manage, booking, Usage]),
          ChecklistItem.new(:invoice_created, booking.invoices.invoice.exists?, [:manage, booking, Invoice])
        ]
      end

      state :payment_due do |booking|
        [
          ChecklistItem.new(:invoices_paid, booking.invoices.all?(:paid), [:manage, booking, Invoice])
        ]
      end

      state :payment_overdue do |booking|
        [
          ChecklistItem.new(:invoices_paid, booking.invoices.all?(:paid), [:manage, booking, Invoice])
        ]
      end
    end
  end
end
