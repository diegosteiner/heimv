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
#  side                :integer          not null
#  amount              :decimal(, )      not null
#  date                :date             not null
#  text                :string
#  currency            :string           not null
#  ordinal             :integer
#  source_document_ref :string
#  book_type           :integer
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
  belongs_to :invoice, inverse_of: :journal_entries
  belongs_to :vat_category, optional: true

  has_one :booking, through: :invoice
  has_one :organisation, through: :booking

  enum :side, { soll: 1, haben: -1 }
  enum :book_type, { main: 0, cost: 1, vat: 2 }, prefix: true, default: :main

  validates :account_nr, :side, :amount, :source_document_ref, :currency, presence: true

  scope :ordered, -> { order(date: :ASC, created_at: :ASC) }

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

  def parallels
    JournalEntry.where(invoice:, source_type:, source_id:).index_by(&:book_type).symbolize_keys
  end

  def self.collect(**defaults, &)
    Collection.new(**defaults).tap(&)
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

    def soll_amount(book_type: %i[main vat])
      journal_entries.filter_map { _1.soll_amount || 0 if Array.wrap(book_type).include?(_1.book_type) }.sum
    end

    def haben_amount(book_type: %i[main vat])
      journal_entries.filter_map { _1.haben_amount || 0 if Array.wrap(book_type).include?(_1.book_type) }.sum
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
        defaults = { source_type: self.class.sti_name, source_id: id, vat_category:, text: "#{invoice.ref} #{label}" }

        collection.haben(**defaults, account_nr: accounting_account_nr, amount: vat_breakdown[:netto])
        collection.haben(**defaults, account_nr: accounting_cost_center_nr,
                                     book_type: :cost, amount: vat_breakdown[:netto])
        collection.haben(**defaults, account_nr: vat_category&.organisation&.accounting_settings&.vat_account_nr,
                                     book_type: :vat, amount: vat_breakdown[:vat])
      end
    end

    def payment(payment) # rubocop:disable Metrics/AbcSize
      payment.instance_eval do
        JournalEntry.collect(currency: organisation.currency, source_document_ref: invoice.ref,
                             date: paid_at, invoice:, source_type: Payment.st_name, source_id: id,
                             text: "#{Payment.model_name.human} #{invoice.ref}") do |collection|
          collection.haben(account_nr: organisation&.accounting_settings&.debitor_account_nr, amount:)
          collection.soll(account_nr: organisation&.accounting_settings&.rental_yield_account_nr, amount: amount)
        end
      end
    end

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
