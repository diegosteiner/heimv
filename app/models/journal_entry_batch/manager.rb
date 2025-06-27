# frozen_string_literal: true

class JournalEntryBatch
  class Manager
    class AccountingMadness < StandardError; end
    extend Implementable

    implement_for(Invoice) do # rubocop:disable Metrics/BlockLength
      attr_reader :invoice

      def initialize(invoice)
        @invoice = invoice
      end

      def handle_save # rubocop:disable Metrics/AbcSize
        previous_journal_entry_batch = existing_journal_entry_batches.processed.last
        raise AccountingMadness if previous_journal_entry_batch&.trigger_invoice_discarded?

        new_journal_entry_batch = factory.build_with_invoice(invoice)
        return true if previous_journal_entry_batch.blank? && invoice.amount.zero?
        return true if new_journal_entry_batch.equivalent?(previous_journal_entry_batch)

        date = invoice.issued_at.to_date
        return new_journal_entry_batch.update(trigger: :invoice_created, date:) if previous_journal_entry_batch.blank?

        date = invoice.updated_at.to_date
        previous_journal_entry_batch.dup.invert.update(trigger: :invoice_updated, date:, processed_at: nil)
        new_journal_entry_batch.update(trigger: :invoice_updated, date:)
      end

      def handle_discard
        previous_journal_entry_batch = existing_journal_entry_batches.processed.last
        return if previous_journal_entry_batch.nil? || previous_journal_entry_batch.trigger_invoice_discarded?

        previous_journal_entry_batch.dup.invert.update(trigger: :invoice_discarded, date: invoice.discarded_at&.to_date,
                                                       processed_at: nil)
      end

      def handle_destroy
        existing_journal_entry_batches.destroy_all
      end

      def existing_journal_entry_batches
        invoice.organisation.journal_entry_batches.where(invoice: invoice).invoice.ordered
      end

      def handle
        return unless invoice.is_a?(Invoices::Deposit) || invoice.is_a?(Invoices::Invoice)

        existing_journal_entry_batches.unprocessed.destroy_all
        return handle_destroy if invoice.destroyed?
        return handle_discard if invoice.discarded?

        handle_save
      end
    end

    implement_for(Payment) do
      attr_reader :payment

      def initialize(payment)
        @payment = payment
      end

      def handle_save # rubocop:disable Metrics/AbcSize
        previous_journal_entry_batch = existing_journal_entry_batches.processed.last
        new_journal_entry_batch = factory.build_with_payment(payment)
        return true if previous_journal_entry_batch.blank? && payment.amount.zero?
        return true if new_journal_entry_batch.equivalent?(previous_journal_entry_batch)

        return new_journal_entry_batch.update!(trigger: :payment_created) if previous_journal_entry_batch.blank?

        date = payment.updated_at.to_date
        previous_journal_entry_batch.dup.invert.update!(trigger: :payment_updated, date:, processed_at: nil)
        new_journal_entry_batch.update!(trigger: :payment_updated, date:) unless payment.amount.zero?
      end

      def handle_destroy
        existing_journal_entry_batches.destroy_all
      end

      def existing_journal_entry_batches
        payment.organisation.journal_entry_batches.where(payment:).payment.ordered
      end

      def handle
        existing_journal_entry_batches.unprocessed.destroy_all
        return handle_destroy if payment.destroyed?

        handle_save
      end
    end

    def factory
      @factory ||= JournalEntryBatch::Factory.new
    end
  end
end
