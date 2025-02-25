# frozen_string_literal: true

class JournalEntry
  class Manager
    class AccountingMadness < StandardError; end
    extend Implementable

    implement_for(Invoice) do # rubocop:disable Metrics/BlockLength
      attr_reader :invoice

      def initialize(invoice)
        @invoice = invoice
      end

      def handle_save # rubocop:disable Metrics/AbcSize
        previous_journal_entry = existing_journal_entries.processed.last
        raise AccountingMadness if previous_journal_entry&.trigger_invoice_discarded?

        new_journal_entry = factory.build_with_invoice(invoice)
        return true if new_journal_entry.equivalent?(previous_journal_entry)

        date = invoice.issued_at.to_date
        return new_journal_entry.update(trigger: :invoice_created, date:) if previous_journal_entry.blank?

        date = invoice.updated_at.to_date
        previous_journal_entry.dup.invert.update(trigger: :invoice_updated, date:, processed_at: nil)
        new_journal_entry.update(trigger: :invoice_updated, date:)
      end

      def handle_discard
        previous_journal_entry = existing_journal_entries.processed.last
        return if previous_journal_entry.nil? || previous_journal_entry.trigger_invoice_discarded?

        previous_journal_entry.dup.invert.update(trigger: :invoice_discarded, date: invoice.discarded_at&.to_date,
                                                 processed_at: nil)
      end

      def handle_destroy
        existing_journal_entries.destroy_all
      end

      def existing_journal_entries
        invoice.organisation.journal_entries.where(invoice: invoice).invoice.ordered
      end

      def handle
        return unless invoice.is_a?(Invoices::Deposit) || invoice.is_a?(Invoices::Invoice)

        existing_journal_entries.unprocessed.destroy_all
        return handle_destroy if invoice.destroyed?

        handle_save
      end
    end

    implement_for(Payment) do
      attr_reader :payment

      def initialize(payment)
        @payment = payment
      end

      def handle_save
        previous_journal_entry = existing_journal_entries.processed.last
        new_journal_entry = factory.build_with_payment(payment)
        return true if new_journal_entry.equivalent?(previous_journal_entry)

        date = payment.updated_at.to_date
        return new_journal_entry.update!(trigger: :payment_created, date:) if previous_journal_entry.blank?

        previous_journal_entry.dup.invert.update!(trigger: :payment_updated, date:, processed_at: nil)
        new_journal_entry.update!(trigger: :payment_updated, date:)
      end

      def handle_destroy
        existing_journal_entries.destroy_all
      end

      def existing_journal_entries
        payment.organisation.journal_entries.where(payment:).payment.ordered
      end

      def handle
        existing_journal_entries.unprocessed.destroy_all
        return handle_destroy if payment.destroyed?

        handle_save
      end
    end

    def factory
      @factory ||= JournalEntry::Factory.new
    end
  end
end
