# == Schema Information
#
# Table name: journal_entries
#
#  id                  :integer          not null, primary key
#  invoice_id          :integer          not null
#  source_type         :string
#  source_id           :integer
#  vat_category_id     :integer
#  account_nr          :string           not null
#  amount              :decimal(, )      not null
#  side                :integer          not null
#  date                :date             not null
#  currency            :string           not null
#  text                :string
#  ordinal             :integer
#  source_document_ref :string
#  cost_center         :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_journal_entries_on_invoice_id       (invoice_id)
#  index_journal_entries_on_source           (source_type,source_id)
#  index_journal_entries_on_vat_category_id  (vat_category_id)
#

# frozen_string_literal: true

class JournalEntry < ApplicationRecord
  belongs_to :invoice
  # belongs_to :vat_category, optional: true

  has_one :booking, through: :invoice
  has_one :organisation, through: :booking

  enum :side, { soll: 1, haben: -1 }
  enum :book_type, { main: 0, cost: 1, vat: 2 }, prefix: true, default: :main

  validates :account_nr, :side, :amount, :source_document_ref, presence: true

  def invert
    return self.side = :soll if haben?
    return self.side = :haben if soll?

    nil
  end

  def soll_account
    account_nr if soll?
  end

  def haben_account
    account_nr if haben?
  end

  def soll_amount
    amount if soll?
  end

  def haben_amount
    amount if haben?
  end

  def self.collect(**defaults, &)
    Collection.new(**defaults).tap(&)
  end

  def self.process_invoice(invoice)
    existing_journal_entry_ids = invoice.reload.journal_entry_ids
    new_journal_entries = JournalEntry::Factory.new.invoice(invoice)

    # raise ActiveRecord::Rollback unless
    new_journal_entries.save && where(id: existing_journal_entry_ids, invoice:).destroy_all
  end

  class Collection
    delegate :[], :to_a, to: :journal_entries

    attr_reader :journal_entries

    def initialize(**defaults)
      @journal_entries = []
      @defaults = defaults
    end

    def collect(journal_entry)
      journal_entry = JournalEntry.new(**@defaults, **journal_entry) if journal_entry.is_a?(Hash)
      return if journal_entry.account_nr.blank? || journal_entry.amount.blank? || journal_entry.amount.zero?

      @journal_entries << journal_entry
    end

    def haben(**args)
      collect(side: :haben, **args)
    end

    def soll(**args)
      collect(side: :soll, **args)
    end

    def soll_amount
      journal_entries.map { _1.soll_amount || 0 }.sum
    end

    def haben_amount
      amount if haben?
    end

    def balanced?
      soll_amount == haben_amount
    end

    def valid?
      journal_entries.all?(&:valid?) # && balanced?
    end

    def save
      valid? && journal_entries.all?(&:save)
    end
  end

  class Filter < ApplicationFilter
    attribute :date_after, :date
    attribute :date_before, :date

    filter :date do |journal_entries|
      next unless date_before.present? || date_after.present?

      journal_entries.where(JournalEntry.arel_table[:date].between(date_after..date_before))
    end
  end

  class Factory
    def invoice(invoice)
      JournalEntry.collect(currency: invoice.currency, source_document_ref: invoice.ref, date: invoice.issued_at,
                           invoice:, text: "#{invoice.ref} - #{invoice.booking.tenant.last_name}") do |collection|
        next unless invoice.is_a?(Invoices::Deposit) || invoice.is_a?(Invoices::Invoice)
        next unless invoice.kept?

        invoice_debitor(invoice, collection)
        invoice.invoice_parts.map { invoice_part(_1, collection) }
      end
    end

    # def discarded_invoice(invoice)
    #   previous_journal_entries = kept_invoice(invoice)
    #   return if previous_journal_entries.blank?

    #   previous_journal_entries + kept_invoice(invoice).each do |journal_entry|
    #     journal_entry.invert
    #     journal_entry.date = invoice.discarded_at.to_date
    #   end
    # end

    def invoice_debitor(invoice, collection)
      invoice.instance_eval do
        defaults = { source_type: ::Invoice.sti_name, source_id: id }

        # Der Betrag, welcher der Debitor noch schuldig ist. (inkl. MwSt.). Jak: «Erlösbuchung»
        collection.soll(**defaults, account_nr: organisation&.accounting_settings&.debitor_account_nr, amount: amount)
      end
    end

    def invoice_part(invoice_part, collection)
      case invoice_part
      when InvoiceParts::Add, InvoiceParts::Deposit
        invoice_part_add(invoice_part, collection)
      end
    end

    def invoice_part_add(invoice_part, collection) # rubocop:disable Metrics/AbcSize
      invoice_part.instance_eval do
        defaults = { source_type: self.class.sti_name, source_id: id, text: "#{invoice.ref} #{label}" }

        collection.haben(**defaults, account_nr: accounting_account_nr, amount: vat_breakdown[:netto])
        collection.haben(**defaults, account_nr: accounting_cost_center_nr, book_type: :cost,
                                     amount: vat_breakdown[:netto])
        collection.haben(**defaults, account_nr: vat_category&.organisation&.accounting_settings&.vat_account_nr,
                                     book_type: :vat, amount: vat_breakdown[:vat])
      end
    end

    # def invoice_part_deposit(invoice_part)
    #   invoice = invoice_part.invoice
    #   cost_center_nr = invoice_part.accounting_cost_center_nr.presence
    #   vat_account_nr = invoice.organisation.accounting_settings.vat_account_nr.presence

    #   JournalEntry.collect(date: invoice.issued_at, invoice: invoice_part.invoice, source_document_ref: invoice.ref,
    #                        source_type: invoice_part.class.sti_name, source_id: id,
    #                        text: "#{invoice.ref} #{invoice_part.label}") do
    #     haben(account_nr:, amount: breakdown[:netto]) if accounting_account_nr.present?
    #     haben(account_nr: cost_center_nr, book_type: :cost, amount: breakdown[:netto]) if cost_center_nr
    #     haben(account_nr:, book_type: :vat, amount: breakdown[:vat]) if vat_category.present? && vat_account_nr
    #   end
    # end

    # def invoice_part_deposit(invoice_part)
    #   invoice_part.instance_eval do
    #     account_nr = tarif&.accounting_account_nr
    #     return if account_nr.blank?

    #     invoice_part_add(invoice_part).tap do |journal_entry|
    #       journal_entry.assign_attributes(account_nr:, side: :haben, amount: -amount)
    #     end
    #   end
    # end

    # def kept_payment(payment)
    #   payment.instance_eval do
    #     account_nr = organisation.accounting_settings.payment_account_nr
    #     return if account_nr.blank? || cost_account_nr.blank?

    #     JournalEntry.new(account_nr:, date: paid_at, side: :soll, amount:, invoice:, currency: organisation.currency,
    #                      source_document_ref: invoice.ref, text: "#{invoice.ref} #{self.class.model_name.human}",
    #                      source_type: ::Payment.sti_name, source_id: id)
    #   end
    # end
  end
end
