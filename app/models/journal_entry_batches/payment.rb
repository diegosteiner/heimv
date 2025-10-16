# frozen_string_literal: true

# == Schema Information
#
# Table name: journal_entry_batches
#
#  id           :bigint           not null, primary key
#  currency     :string           not null
#  date         :date             not null
#  entries      :jsonb
#  fragments    :jsonb
#  processed_at :datetime
#  ref          :string
#  text         :string
#  trigger      :integer          not null
#  type         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  booking_id   :uuid             not null
#  invoice_id   :bigint
#  payment_id   :bigint
#
module JournalEntryBatches
  class Payment < ::JournalEntryBatch
    JournalEntryBatch.register_subtype self

    validates :payment, presence: true

    def self.handle_save(payment)
      previous_batch = existing_batches(payment).processed.last
      new_batch = build_with_payment(payment)
      return true if previous_batch.blank? && payment.amount.zero?
      return true if new_batch.equivalent?(previous_batch)
      return new_batch.update!(trigger: :payment_created) if previous_batch.blank?

      date = payment.updated_at.to_date
      previous_batch.dup.invert.update!(trigger: :payment_reverted, date:, processed_at: nil)
      new_batch.update!(trigger: :payment_updated, date:) unless payment.amount.zero?
    end

    def self.handle_destroy(payment)
      existing_batches(payment).destroy_all
    end

    def self.handle_discard(payment)
      previous_batch = existing_batches(payment).processed.last
      return if previous_batch.nil? || previous_batch.trigger_payment_discarded?

      previous_batch.dup.invert.update(trigger: :payment_discarded, date: payment.discarded_at&.to_date,
                                       processed_at: nil)
    end

    def self.existing_batches(payment)
      payment.organisation.journal_entry_batches.where(payment:).payment.ordered
    end

    def self.handle(payment)
      existing_batches(payment).unprocessed.destroy_all
      return handle_destroy(payment) if payment.destroyed?
      return handle_discard(payment) if payment.discarded?

      handle_save(payment)
    end

    def self.build_with_payment(payment, **attributes)
      text = "#{::Payment.model_name.human} #{payment.invoice&.ref || payment&.paid_at}"
      invoice = payment.invoice
      booking = payment.booking

      new(ref: payment.id, date: payment.paid_at, text:, invoice:, payment:, booking:, **attributes).tap do |batch|
        if payment.write_off
          build_with_payment_write_off(batch, payment, text:)
        else
          build_with_paid_payment(batch, payment, text:)
        end
      end
    end

    def self.build_with_paid_payment(batch, payment, text:)
      batch.entry(amount: payment.amount, text:,
                  haben_account: payment.organisation.accounting_settings&.debitor_account_nr,
                  soll_account: payment.accounting_account_nr.presence ||
                                payment.organisation.accounting_settings&.payment_account_nr,
                  cost_center: payment.accounting_cost_center_nr).abs
    end

    def self.build_with_payment_write_off(batch, payment, text:)
      return unless payment.write_off

      batch.entry(amount: payment.amount, text:,
                  haben_account: payment.organisation.accounting_settings&.debitor_account_nr,
                  soll_account: payment.accounting_account_nr.presence ||
                                 payment.organisation.accounting_settings&.rental_yield_account_nr,
                  cost_center: payment.accounting_cost_center_nr)
    end
  end
end
