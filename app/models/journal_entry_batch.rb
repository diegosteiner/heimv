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

# frozen_string_literal: true

class JournalEntryBatch < ApplicationRecord
  include Subtypeable
  include StoreModel::NestedAttributes

  belongs_to :booking
  belongs_to :invoice, inverse_of: :journal_entry_batches, optional: true
  belongs_to :payment, inverse_of: :journal_entry_batches, optional: true

  has_one :organisation, through: :booking

  enum :trigger, { invoice_created: 11, invoice_updated: 12, invoice_discarded: 13, invoice_reverted: 14,
                   payment_created: 21, payment_updated: 22, payment_discarded: 23, payment_reverted: 24 }, prefix: true

  attribute :entries, Entry.to_array_type, default: -> { [] }
  attribute :processed, :boolean

  accepts_nested_attributes_for :entries, allow_destroy: true

  before_validation :set_currency, :set_processed_at

  validates :ref, :currency, :date, :trigger, presence: true
  validates :entries, store_model: true
  validate do
    # Ensure batch is only composed of one businesscase. This should never happen
    error.add(:entries, :invalid) if !accounts[:soll].count == 1 && !accounts[:haben].count == 1
  end

  scope :ordered, -> { order(date: :ASC, created_at: :ASC) }
  scope :processed, -> { where.not(processed_at: nil) }
  scope :unprocessed, -> { where(processed_at: nil) }

  # this can be replaced with type: sti_name
  scope :invoice, -> { where(trigger: %i[invoice_created invoice_updated invoice_discarded]) }
  scope :payment, -> { where(trigger: %i[payment_created payment_updated payment_discarded]) }

  delegate :accounting_settings, to: :organisation, allow_nil: true

  def set_currency
    self.currency ||= organisation&.currency
  end

  def to_s
    "##{id}@#{date}: #{text}\n" + entries.map(&:to_s).join("\n")
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

    (attributes.slice(*%w[booking_id invoice_id payment_id]) ==
      other.attributes.slice(*%w[booking_id invoice_id payment_id])) &&
      entries.each_with_index.all? { |entry, index| entry.equivalent?(other.entries[index]) }
  end

  def invert
    entries.each(&:invert)
    self
  end

  def entry(soll_account:, haben_account:, amount:, **attributes)
    Entry.new(soll_account:, haben_account:, amount:, **attributes).tap do |entry|
      entries << entry
    end
  end

  def accounts
    { soll: Set[*entries.map(&:soll_account)], haben: Set[*entries.map(&:haben_account)] }
  end

  def amount
    entries.sum(&:amount)
  end
end
