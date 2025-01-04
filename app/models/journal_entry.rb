# == Schema Information
#
# Table name: journal_entries
#
#  id              :integer          not null, primary key
#  invoice_id      :integer
#  vat_category_id :integer
#  account_nr      :string           not null
#  side            :integer          not null
#  amount          :decimal(, )      not null
#  date            :date             not null
#  text            :string
#  currency        :string           not null
#  ordinal         :integer
#  ref             :string
#  book_type       :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  invoice_part_id :integer
#  payment_id      :integer
#  trigger         :integer          not null
#  booking_id      :uuid             not null
#  processed_at    :datetime
#
# Indexes
#
#  index_journal_entries_on_booking_id       (booking_id)
#  index_journal_entries_on_invoice_id       (invoice_id)
#  index_journal_entries_on_invoice_part_id  (invoice_part_id)
#  index_journal_entries_on_payment_id       (payment_id)
#  index_journal_entries_on_vat_category_id  (vat_category_id)
#

# frozen_string_literal: true

class JournalEntry < ApplicationRecord
  belongs_to :booking
  belongs_to :invoice, inverse_of: :journal_entries, optional: true
  belongs_to :invoice_part, inverse_of: :journal_entries, optional: true
  belongs_to :payment, inverse_of: :journal_entries, optional: true
  belongs_to :vat_category, optional: true

  has_one :organisation, through: :booking

  enum :side, { soll: 1, haben: -1 }
  enum :book_type, { main: 0, cost: 1, vat: 2 }, prefix: true, default: :main
  enum :trigger, { manual: 0, invoice_created: 1, payment_created: 2 }, prefix: true

  before_validation :set_currency

  validates :account_nr, :side, :amount, :ref, :currency, :date, :trigger, presence: true

  scope :ordered, -> { order(date: :ASC, ordinal: :ASC, created_at: :ASC) }
  scope :processed, -> { where.not(processed_at: nil) }
  scope :unprocessed, -> { where(processed_at: nil) }

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

  def set_currency
    self.currency ||= organisation&.currency
  end

  def related
    @related ||= JournalEntry.where(booking:, invoice:, payment:, invoice_part:, trigger:, date:, ref:)
                             .index_by(&:book_type).symbolize_keys
  end

  def self.collect(**defaults, &)
    Compound.new(**defaults).tap(&)
  end

  class Compound
    COMPOUND_ATTRIBUTES = %i[booking_id invoice_id payment_id date trigger ref].freeze

    delegate :[], :to_a, :<<, to: :journal_entries

    attr_reader :common, :defaults
    attr_accessor :journal_entries

    def initialize(journal_entries = [], **defaults)
      @journal_entries = journal_entries
      @defaults = defaults
      @common = defaults.slice(*COMPOUND_ATTRIBUTES)
    end

    def collect(journal_entry)
      journal_entry = JournalEntry.new(**defaults, **journal_entry) if journal_entry.is_a?(Hash)
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
      journal_entries.all?(&:valid?) && balanced?
    end

    def save!
      raise ActiveRecord::RecordInvalid unless valid?

      journal_entries.each_with_index { |journal_entry, ordinal| journal_entry.update!(ordinal:) }
    end

    def ==(other)
      common == other.common
    end

    def self.group(journal_entries)
      journal_entries.each_with_object([]) do |journal_entry, compounds|
        common = journal_entry.attributes.symbolize_keys.slice(*COMPOUND_ATTRIBUTES)
        compound = compounds.find { _1.common == common }
        compounds << compound = new(**common) if compound.nil?
        compound.journal_entries << journal_entry
      end
    end
  end

  class Filter < ApplicationFilter
    attribute :date_after, :date
    attribute :date_before, :date
    attribute :processed_at_after, :date
    attribute :processed_at_before, :date
    attribute :processed, :boolean

    filter :date do |journal_entries|
      next unless date_before.present? || date_after.present?

      journal_entries.where(JournalEntry.arel_table[:date].between(date_after..date_before))
    end

    filter :processed do |journal_entries|
      next if processed.nil?

      processed ? journal_entries.processed : journal_entries.unprocessed
    end

    filter :processed_at do |journal_entries|
      next unless processed_at_before.present? || processed_at_after.present?

      journal_entries.where(JournalEntry.arel_table[:processed_at].between(processed_at_after..processed_at_before))
    end
  end

  class Factory
    def invoice(invoice)
      text = "#{invoice.ref} - #{invoice.booking.tenant.last_name}"
      JournalEntry.collect(ref: invoice.ref, date: invoice.issued_at, invoice:,
                           booking: invoice.booking, trigger: :invoice_created, text:) do |compound|
        next unless invoice.is_a?(Invoices::Deposit) || invoice.is_a?(Invoices::Invoice)
        next unless invoice.kept?

        invoice_debitor(invoice, compound)
        invoice.invoice_parts.map { invoice_part(_1, compound) }
      end
    end

    def invoice_debitor(invoice, compound)
      invoice.instance_eval do
        # Der Betrag, welcher der Debitor noch schuldig ist. (inkl. MwSt.). Jak: «Erlösbuchung»
        compound.soll(account_nr: organisation&.accounting_settings&.debitor_account_nr, amount:)
      end
    end

    def invoice_part(invoice_part, compound)
      case invoice_part
      when InvoiceParts::Add, InvoiceParts::Deposit
        invoice_part_add(invoice_part, compound)
      end
    end

    def invoice_part_add(invoice_part, compound) # rubocop:disable Metrics/AbcSize
      invoice_part.instance_eval do
        defaults = { invoice_part:, vat_category:, text: "#{invoice.ref} #{label}" }

        compound.haben(**defaults, account_nr: accounting_account_nr, amount: vat_breakdown[:netto])
        compound.haben(**defaults, account_nr: accounting_cost_center_nr,
                                   book_type: :cost, amount: vat_breakdown[:netto])
        compound.haben(**defaults, account_nr: vat_category&.organisation&.accounting_settings&.vat_account_nr,
                                   book_type: :vat, amount: vat_breakdown[:vat])
      end
    end

    def payment(payment) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity
      payment.instance_eval do
        text = "#{Payment.model_name.human} #{invoice&.ref || paid_at}"
        JournalEntry.collect(ref: id, date: paid_at, invoice:,
                             payment: self, text:, booking:, trigger: :payment_created) do |compound|
          compound.soll(account_nr: organisation&.accounting_settings&.payment_account_nr, amount:)
          compound.haben(account_nr: organisation&.accounting_settings&.debitor_account_nr, amount:)
        end
      end
    end
  end
end
