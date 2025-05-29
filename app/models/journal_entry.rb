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
#  text         :string
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

  enum :trigger, { invoice_created: 11, invoice_updated: 12, invoice_discarded: 13,
                   payment_created: 21, payment_updated: 22, payment_discarded: 23 }, prefix: true

  attribute :fragments, Fragment.to_array_type, default: -> { [] }
  attribute :processed, :boolean

  accepts_nested_attributes_for :fragments, allow_destroy: true

  before_validation :set_currency, :set_processed_at

  validates :ref, :currency, :date, :trigger, presence: true
  validates :fragments, store_model: true
  validate { errors.add(:base, :invalid) unless balanced? }
  validate do
    accounts = {
      soll: fragments.count { |fragment| fragment.soll_account.present? },
      haben: fragments.count { |fragment| fragment.haben_account.present? }
    }
    errors.add(:base, :invalid) if accounts.values.min < 1
  end

  scope :ordered, -> { order(date: :ASC, created_at: :ASC) }
  scope :processed, -> { where.not(processed_at: nil) }
  scope :unprocessed, -> { where(processed_at: nil) }
  scope :invoice, -> { where(trigger: %i[invoice_created invoice_updated invoice_discarded]) }
  scope :payment, -> { where(trigger: %i[payment_created payment_updated payment_discarded]) }

  def set_currency
    self.currency ||= organisation&.currency
  end

  def related
    @related ||= fragments.index_by(&:book_type).symbolize_keys
  end

  def soll_amount(book_type: %i[main vat])
    fragments.filter_map { it.soll_amount || 0 if Array.wrap(book_type).include?(it.book_type&.to_sym) }.sum
  end

  def haben_amount(book_type: %i[main vat])
    fragments.filter_map { it.haben_amount || 0 if Array.wrap(book_type).include?(it.book_type&.to_sym) }.sum
  end

  def haben(**args)
    fragment = Fragment.new(side: :haben, **args)
    fragments << fragment if fragment&.valid?
  end

  def soll(**args)
    fragment = Fragment.new(side: :soll, **args)
    fragments << fragment if fragment&.valid?
  end

  def to_s
    soll_accounts = fragments.filter(&:soll?).uniq.map(&:account_nr).join(',')
    haben_accounts = fragments.filter(&:haben?).uniq.map(&:account_nr).join(',')
    "##{id}: (#{soll_accounts}) => (#{haben_accounts}) " +
      ActiveSupport::NumberHelper.number_to_currency(soll_amount)
  end

  def balanced?
    soll_amount == haben_amount
  end

  def amount
    balanced? && soll_amount
  end

  def processed?
    processed_at.present?
  end

  def set_processed_at
    return if processed.nil?

    if processed.present?
      self.processed_at ||= Time.zone.now
    else
      self.processed_at = nil
    end
  end

  def equivalent?(other)
    return false if other.blank?

    attributes.slice(*%w[booking_id invoice_id payment_id]) ==
      other.attributes.slice(*%w[booking_id invoice_id payment_id]) &&
      fragments.each_with_index.all? { |fragment, index| fragment.equivalent?(other.fragments[index]) }
  end

  def invert
    fragments.each(&:invert)
    self
  end

  # TODO: check move
  def fragment_relations
    fragments.group_by(&:invoice_part_id).transform_values do |related_fragments|
      related_fragments.group_by(&:book_type).transform_values(&:first).symbolize_keys
    end
  end

  class Filter < ApplicationFilter
    attribute :date_after, :date
    attribute :date_before, :date
    attribute :processed_at_after, :date
    attribute :processed_at_before, :date
    attribute :processed, :boolean
    attribute :triggers, array: true

    filter :date do |journal_entries|
      next unless date_before.present? || date_after.present?

      journal_entries.where(JournalEntry.arel_table[:date].between(date_after..date_before))
    end

    filter :processed_at do |journal_entries|
      next unless processed_at_before.present? || processed_at_after.present?

      journal_entries.where(JournalEntry.arel_table[:date].between(processed_at_after..processed_at_before))
    end

    filter :processed do |journal_entries|
      next if processed.nil?

      processed ? journal_entries.processed : journal_entries.unprocessed
    end

    filter :triggers do |journal_entries|
      trigger = Array.wrap(triggers) & JournalEntry.triggers.keys
      next if triggers.blank?

      journal_entries.where(trigger:)
    end
  end

  class Factory
    def build_with_invoice(invoice, attributes = {})
      text = "#{invoice.ref} - #{invoice.booking.tenant.last_name}"
      JournalEntry.new(ref: invoice.ref, date: invoice.issued_at, invoice:, booking: invoice.booking, text:,
                       **attributes).tap do |journal_entry|
        build_invoice_debitor(invoice, journal_entry)
        invoice.invoice_parts.map { build_invoice_part(it, journal_entry) }
      end
    end

    def build_invoice_debitor(invoice, journal_entry)
      invoice.instance_eval do
        text = "#{ref} - #{booking.tenant.last_name}"
        # Der Betrag, welcher der Debitor noch schuldig ist. (inkl. MwSt.). Jak: «Erlösbuchung»
        journal_entry.soll(account_nr: organisation&.accounting_settings&.debitor_account_nr || 0, amount:, text:)
      end
    end

    def build_invoice_part(invoice_part, journal_entry)
      case invoice_part
      when InvoiceParts::Add, InvoiceParts::Deposit
        build_invoice_part_add(invoice_part, journal_entry)
      end
    end

    def build_invoice_part_add(invoice_part, journal_entry) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      invoice_part.instance_eval do
        text = "#{invoice.ref} - #{invoice.booking.tenant.last_name}: #{label}"
        accounting_settings = organisation.accounting_settings

        journal_entry.haben(account_nr: accounting_account_nr.presence ||
                              accounting_settings&.rental_yield_account_nr.presence || 0,
                            amount: vat_breakdown[:netto], invoice_part_id: id, vat_category_id:, text:)
        journal_entry.haben(account_nr: accounting_cost_center_nr, book_type: :cost,
                            amount: vat_breakdown[:netto], invoice_part_id: id, vat_category_id:, text:)
        journal_entry.haben(account_nr: accounting_settings&.vat_account_nr, book_type: :vat,
                            amount: vat_breakdown[:vat], invoice_part_id: id, vat_category_id:, text:)
      end
    end

    def build_with_payment(payment)
      text = "#{Payment.model_name.human} #{payment.invoice&.ref || payment&.paid_at}"

      if payment.write_off
        build_with_payment_write_off(payment, text:)
      else
        build_with_payment_normal(payment, text:)
      end
    end

    def build_with_payment_normal(payment, **attributes)
      payment.instance_eval do
        text = attributes[:text]
        JournalEntry.new(ref: id, date: paid_at, invoice:, payment: self, booking:,
                         trigger: :payment_created).tap do |journal_entry|
          journal_entry.soll(account_nr: accounting_account_nr || organisation&.accounting_settings&.payment_account_nr,
                             amount:, text:)
          journal_entry.haben(account_nr: organisation&.accounting_settings&.debitor_account_nr, amount:, text:)
        end
      end
    end

    def build_with_payment_write_off(payment, **attributes)
      payment.instance_eval do
        text = attributes[:text]
        JournalEntry.new(ref: id, date: paid_at, invoice:, payment: self, booking:,
                         trigger: :payment_created, **attributes).tap do |journal_entry|
          journal_entry.haben(account_nr: accounting_account_nr ||
          organisation&.accounting_settings&.rental_yield_account_nr,
                              amount:, text:)
          journal_entry.soll(account_nr: organisation&.accounting_settings&.debitor_account_nr, amount:, text:)
        end
      end
    end
  end
end
