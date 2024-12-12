# == Schema Information
#
# Table name: journal_entries
#
#  id                  :integer          not null, primary key
#  booking_id          :uuid             not null
#  source_type         :string           not null
#  source_id           :integer          not null
#  account_nr          :string           not null
#  vat_category_id     :integer
#  date                :date             not null
#  amount              :decimal(, )      not null
#  side                :integer          not null
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
#  index_journal_entries_on_source           (source_type,source_id)
#  index_journal_entries_on_vat_category_id  (vat_category_id)
#

# frozen_string_literal: true

class JournalEntry < ApplicationRecord
  belongs_to :booking
  belongs_to :source, polymorphic: true
  belongs_to :vat_category, optional: true

  has_one :organisation, through: :booking

  enum :side, { soll: 1, haben: -1 }

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

  def self.balanced?(journal_entries)
    journal_entries.map { _1.soll_amount || 0 }.sum == journal_entries.map { _1.haben_amount || 0 }.sum
  end

  def to_s
    [
      (id || index).presence&.then { "[#{_1}]" },
      soll_account,
      '->',
      haben_account,
      ActiveSupport::NumberHelper.number_to_currency(amount, unit: currency),
      ':',
      text
    ].compact.join(' ')
  end

  def self.generate(source, booking: source.booking)
    existing_journal_entry_ids = source.reload.journal_entry_ids
    new_journal_entries = Array.wrap(JournalEntry::Factory.new.source(source)).compact

    # raise ActiveRecord::Rollback unless
    new_journal_entries.all?(&:valid?) && balanced?(new_journal_entries) &&
      new_journal_entries.all?(&:save) &&
      where(id: existing_journal_entry_ids, booking:).destroy_all
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
    def source(source)
      case source
      when Invoice
        source.kept? ? kept_invoice(source) : discarded_invoice(source)
      when Payment
        source.kept? ? kept_payment(source) : discarded_payment(source)
      end
    end

    def kept_invoice(invoice)
      return unless invoice.is_a?(Invoices::Deposit) || invoice.is_a?(Invoices::Invoice)

      [invoice_debitor(invoice)] + invoice.invoice_parts.map { invoice_part(_1) }.compact
    end

    def discarded_invoice(invoice)
      previous_journal_entries = kept_invoice(invoice)
      return if previous_journal_entries.blank?

      previous_journal_entries + kept_invoice(invoice).each do |journal_entry|
        journal_entry.invert
        journal_entry.date = invoice.discarded_at.to_date
      end
    end

    def invoice_debitor(invoice)
      invoice.instance_eval do
        account_nr = organisation.accounting_settings.debitor_account_nr
        return if account_nr.blank?

        JournalEntry.new(account_nr:, date: issued_at, side: :soll, amount:, source_document_ref: ref,
                         source: self, currency:, booking:,
                         text: "#{ref} - #{booking.tenant.last_name}")
      end
    end

    def invoice_part(invoice_part)
      case invoice_part
      when InvoiceParts::Add
        invoice_part_add(invoice_part)
      when InvoiceParts::Deposit
        invoice_part_deposit(invoice_part)
      end
    end

    def invoice_part_add(invoice_part) # rubocop:disable Metrics/AbcSize
      invoice_part.instance_eval do
        account_nr = tarif&.accounting_account_nr
        return if account_nr.blank?

        JournalEntry.new(account_nr:, date: invoice.issued_at, side: :haben,
                         amount:, vat_category:, source_document_ref: invoice.ref, source: invoice,
                         currency: organisation.currency, booking:, cost_center: tarif&.accounting_profit_center_nr,
                         text: "#{invoice.ref} #{label}")
      end
    end

    def invoice_part_deposit(invoice_part) # rubocop:disable Metrics/AbcSize
      invoice_part.instance_eval do
        account_nr = tarif&.accounting_account_nr
        return if account_nr.blank?

        JournalEntry.new(account_nr:, date: invoice.issued_at, side: :soll,
                         amount:, source_document_ref: invoice.ref, source: invoice,
                         currency: organisation.currency, booking:, cost_center: tarif&.accounting_profit_center_nr,
                         text: "#{invoice.ref} #{label}")
      end
    end

    def kept_payment(payment) # rubocop:disable Metrics/AbcSize
      payment.instance_eval do
        account_nr = organisation.accounting_settings.payment_account_nr
        return if account_nr.blank?

        JournalEntry.new(account_nr:, date: paid_at, side: :soll, amount:,
                         source_document_ref: invoice.ref, source: self, currency: organisation.currency, booking:,
                         text: "#{invoice.ref} #{self.class.model_name.human}")
      end
    end
  end
end
