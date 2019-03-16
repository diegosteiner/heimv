module BookingStrategies
  class Default
    class Checklist < BookingStrategy::Checklist
      state :definitive_request do |booking|
        [
          ChecklistItem.new(:choose_tarifs, booking.booking_copy_tarifs.exists?, [:manage, booking, Tarif]),
          ChecklistItem.new(:create_contract, booking.contract.present?, [:manage, booking, Contract]),
          ChecklistItem.new(:create_deposit, booking.invoices.deposit.exists?, [:manage, booking, Invoice])
        ]
      end

      state :confirmed do |booking|
        [
          ChecklistItem.new(:deposit_paid, booking.invoices.deposit.all?(&:paid), [:manage, booking, Invoice]),
          ChecklistItem.new(:contract_signed, booking.contracts.signed.exists?, [:manage, booking, Contract])
        ]
      end

      state :overdue do |booking|
        [
          ChecklistItem.new(:deposit_paid, booking.invoices.deposit.all?(&:paid), [:manage, booking, Invoice]),
          ChecklistItem.new(:contract_signed, booking.contracts.signed.exists?, [:manage, booking, Contract])
        ]
      end

      state :past do |booking|
        [
          ChecklistItem.new(:create_usages, booking.usages_entered?, [:manage, booking, Usage]),
          ChecklistItem.new(:create_invoice, booking.invoices.invoice.exists?, [:manage, booking, Invoice])
        ]
      end

      state :payment_due do |booking|
        [
          ChecklistItem.new(:invoice_paid, booking.invoices.all?(&:paid), [:manage, booking, Invoice])
        ]
      end

      state :payment_overdue do |booking|
        [
          ChecklistItem.new(:invoice_paid, booking.invoices.all?(&:paid), [:manage, booking, Invoice])
        ]
      end
    end
  end
end
