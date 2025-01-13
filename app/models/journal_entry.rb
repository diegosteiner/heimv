# == Schema Information
#
# Table name: journal_entries
#
#  id           :bigint           not null, primary key
#  currency     :string           not null
#  date         :date             not null
#  fragments    :jsonb
#  processed_at :datetime
#  ref          :string
#  trigger      :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  booking_id   :uuid             not null
#  invoice_id   :bigint
#  payment_id   :bigint
#

# frozen_string_literal: true

class JournalEntry < ApplicationRecord
  include StoreModel::NestedAttributes

  belongs_to :booking
  belongs_to :invoice, inverse_of: :journal_entries, optional: true
  belongs_to :payment, inverse_of: :journal_entries, optional: true

  has_one :organisation, through: :booking

  enum :trigger, { manual: 0, invoice_created: 1, payment_created: 2 }, prefix: true

  attribute :fragments, Fragment.to_array_type, default: -> { [] }

  accepts_nested_attributes_for :fragments, allow_destroy: true

  before_validation :set_currency

  validates :ref, :currency, :date, :trigger, presence: true
  validates :fragments, store_model: true
  validate { errors.add(:fragments, :invalid) unless balanced? }

  scope :ordered, -> { order(date: :ASC, created_at: :ASC) }

  def set_currency
    self.currency ||= organisation&.currency
  end

  def related
    @related ||= fragments.index_by(&:book_type).symbolize_keys
  end

  def soll_amount(book_type: %i[main vat])
    fragments.filter_map { _1.soll_amount || 0 if Array.wrap(book_type).include?(_1.book_type) }.sum
  end

  def haben_amount(book_type: %i[main vat])
    fragments.filter_map { _1.haben_amount || 0 if Array.wrap(book_type).include?(_1.book_type) }.sum
  end

  def haben(**args)
    fragment = Fragment.new(side: :haben, **args)
    fragments << fragment if fragment&.valid?
  end

  def soll(**args)
    fragment = Fragment.new(side: :soll, **args)
    fragments << fragment if fragment&.valid?
  end

  def balanced?
    soll_amount == haben_amount
  end

  def fragment_relations
    fragments.group_by(&:invoice_part_id).transform_values do |related_fragments|
      related_fragments.group_by(&:book_type).transform_values(&:first).symbolize_keys
    end
  end

  class Filter < ApplicationFilter
    attribute :date_after, :date
    attribute :date_before, :date
    # attribute :processed_at_after, :date
    # attribute :processed_at_before, :date
    # attribute :processed, :boolean

    filter :date do |journal_entries|
      next unless date_before.present? || date_after.present?

      journal_entries.where(JournalEntry.arel_table[:date].between(date_after..date_before))
    end

    # filter :processed do |journal_entries|
    #   next if processed.nil?

    #   processed ? journal_entries.processed : journal_entries.unprocessed
    # end

    # filter :processed_at do |journal_entries|
    #   next unless processed_at_before.present? || processed_at_after.present?

    #   journal_entries.where(JournalEntry.arel_table[:processed_at].between(processed_at_after..processed_at_before))
    # end
  end

  class Factory
    def build_invoice_created(invoice)
      JournalEntry.new(ref: invoice.ref, date: invoice.issued_at, invoice:, booking: invoice.booking,
                       trigger: :invoice_created).tap do |journal_entry|
        next unless invoice.is_a?(Invoices::Deposit) || invoice.is_a?(Invoices::Invoice)
        next unless invoice.kept?

        build_invoice_debitor(invoice, journal_entry)
        invoice.invoice_parts.map { build_invoice_part(_1, journal_entry) }
      end
    end

    def build_invoice_debitor(invoice, journal_entry)
      invoice.instance_eval do
        text = "R.#{ref} - #{booking.tenant.last_name}"
        # Der Betrag, welcher der Debitor noch schuldig ist. (inkl. MwSt.). Jak: «Erlösbuchung»
        journal_entry.soll(account_nr: organisation&.accounting_settings&.debitor_account_nr, amount:, text:)
      end
    end

    def build_invoice_part(invoice_part, journal_entry)
      case invoice_part
      when InvoiceParts::Add, InvoiceParts::Deposit
        build_invoice_part_add(invoice_part, journal_entry)
      end
    end

    def build_invoice_part_add(invoice_part, journal_entry) # rubocop:disable Metrics/AbcSize
      invoice_part.instance_eval do
        text = "R.#{invoice.ref} - #{invoice.booking.tenant.last_name}: #{label}"

        journal_entry.haben(account_nr: accounting_account_nr, amount: vat_breakdown[:netto],
                            invoice_part_id: id, vat_category_id:, text:)
        journal_entry.haben(account_nr: accounting_cost_center_nr, amount: vat_breakdown[:netto],
                            book_type: :cost, invoice_part_id: id, vat_category_id:, text:)
        journal_entry.haben(account_nr: vat_category&.organisation&.accounting_settings&.vat_account_nr,
                            amount: vat_breakdown[:vat], book_type: :vat, invoice_part_id: id, vat_category_id:, text:)
      end
    end

    def payment(payment) # rubocop:disable Metrics/AbcSize
      payment.instance_eval do
        text = "#{Payment.model_name.human} #{invoice&.ref || paid_at}"

        JournalEntry.new(ref: id, date: paid_at, invoice:, payment: self, booking:,
                         trigger: :payment_created).tap do |journal_entry|
          journal_entry.soll(account_nr: organisation&.accounting_settings&.payment_account_nr, amount:, text:)
          journal_entry.haben(account_nr: organisation&.accounting_settings&.debitor_account_nr, amount:, text:)
        end
      end
    end
  end
end
