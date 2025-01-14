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

      def handle_create
        return unless invoice.is_a?(Invoices::Deposit) || invoice.is_a?(Invoices::Invoice)
        return unless invoice.kept?
        raise AccoundingMadness, 'no journal_entries must exist before create' if existing_journal_entries.exists?

        factory.build_with_invoice(invoice).update(trigger: :invoice_created)
      end

      def handle_update
        previous_journal_entry = existing_journal_entries.last
        raise AccoundingMadness if previous_journal_entry.trigger_invoice_discarded?

        new_journal_entry = factory.build_with_invoice(invoice)
        return if previous_journal_entry.nil? || previous_journal_entry.equivalent?(new_journal_entry)

        date = invoice.updated_at.to_date
        previous_journal_entry.dup.invert.update(trigger: :invoice_updated, date:)
        new_journal_entry.update(trigger: :invoice_updated, date:)
      end

      def handle_discard
        previous_journal_entry = existing_journal_entries.last
        return if previous_journal_entry.nil? || previous_journal_entry.trigger_invoice_discarded?

        previous_journal_entry.dup.invert.update(trigger: :invoice_discarded, date: invoice.discarded_at&.to_date)
      end

      def handle_destroy
        existing_journal_entries.destroy_all
      end

      def existing_journal_entries
        invoice.organisation.journal_entries.where(invoice: invoice, payment: nil).order(date: :ASC, created_at: :ASC)
      end

      def handle
        return handle_destroy if invoice.destroyed?
        return handle_create unless existing_journal_entries.exists?
        return handle_discard if invoice.discarded?

        handle_update
      end
    end

    implement_for(Payment) do # rubocop:disable Metrics/BlockLength
      attr_reader :payment

      def initialize(payment)
        @payment = payment
      end

      def handle_create
        raise AccoundingMadness, 'no journal_entries must exist before create' if existing_journal_entries.exists?

        factory.build_with_payment(payment).update(trigger: :payment_created)
      end

      def handle_update
        previous_journal_entry = existing_journal_entries.last
        new_journal_entry = factory.build_with_payment(payment)
        return if previous_journal_entry&.equivalent?(new_journal_entry)

        date = payment.updated_at.to_date
        previous_journal_entry.dup.invert.update(trigger: :payment_updated, date:)
        new_journal_entry.update(trigger: :payment_updated, date:)
      end

      def handle_destroy
        existing_journal_entries.destroy_all
      end

      def existing_journal_entries
        payment.organisation.journal_entries.where(payment:).order(date: :ASC, created_at: :ASC)
      end

      def handle
        return handle_destroy if payment.destroyed?
        return handle_create unless existing_journal_entries.exists?

        handle_update
      end
    end

    def factory
      @factory ||= JournalEntry::Factory.new
    end
  end
end
