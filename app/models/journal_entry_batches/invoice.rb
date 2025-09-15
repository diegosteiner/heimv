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
  class Invoice < ::JournalEntryBatch
    JournalEntryBatch.register_subtype self

    def self.handle(invoice)
      return unless invoice.is_a?(::Invoices::Deposit) || invoice.is_a?(::Invoices::Invoice)

      existing_batches(invoice).unprocessed.destroy_all
      return handle_destroy(invoice) if invoice.destroyed?
      return handle_discard(invoice) if invoice.discarded?

      handle_save(invoice)
    end

    def self.handle_save(invoice)
      previous_batch = existing_batches(invoice).processed.last
      return true if previous_batch.blank? && invoice.amount.zero?

      new_batch = build_with_invoice(invoice)
      return true if new_batch.equivalent?(previous_batch)

      date = invoice.issued_at.to_date
      return new_batch.update!(trigger: :invoice_created, date:) if previous_batch.blank?

      date = invoice.updated_at.to_date
      previous_batch.dup.invert.update!(trigger: :invoice_reverted, date:, processed_at: nil)
      new_batch.update!(trigger: :invoice_updated, date:)
    end

    def self.handle_discard(invoice)
      previous_batch = existing_batches(invoice).processed.last
      return if previous_batch.nil? || previous_batch.trigger_invoice_discarded?

      previous_batch.dup.invert.update(trigger: :invoice_discarded, date: invoice.discarded_at&.to_date,
                                       processed_at: nil)
    end

    def self.handle_destroy(invoice)
      existing_batches(invoice).destroy_all
    end

    def self.existing_batches(invoice)
      invoice.organisation.journal_entry_batches.where(invoice:, type: sti_name).invoice.ordered
    end

    def self.build_with_invoice(invoice, **attributes)
      return unless invoice.is_a?(::Invoices::Deposit) || invoice.is_a?(::Invoices::Invoice)

      booking = invoice.booking
      date = invoice.issued_at

      new(ref: invoice.ref, date:, invoice:, booking:, text: invoice_text(invoice), **attributes).tap do |batch|
        invoice.items.each { build_with_item(batch, it) }
      end
    end

    def self.build_with_item(batch, item)
      case item
      when ::Invoice::Items::Add, ::Invoice::Items::Deposit
        build_with_add_item(batch, item)
      when ::Invoice::Items::Balance
        # No journal entries for balance
      end
    end

    def self.build_with_add_item(batch, item)
      text = item_text(item)

      item.instance_exec do
        batch.entry(soll_account: organisation.accounting_settings&.debitor_account_nr || 0,
                    haben_account: accounting_account_nr ||
                        organisation.accounting_settings&.rental_yield_account_nr.presence || 0,
                    text:, invoice_item_id: id, amount:, vat_amount: vat_breakdown[:vat], vat_category_id:,
                    cost_center: accounting_cost_center_nr.presence)
      end
    end

    def self.item_text(item)
      "#{item.invoice.model_name.human} #{item.invoice.ref}: #{item.label}"
    end

    def self.invoice_text(invoice)
      "#{invoice.model_name.human} #{invoice.ref} #{invoice.booking.ref}"
    end
  end
end
