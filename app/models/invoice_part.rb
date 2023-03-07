# frozen_string_literal: true

# == Schema Information
#
# Table name: invoice_parts
#
#  id         :bigint           not null, primary key
#  amount     :decimal(, )
#  breakdown  :string
#  label      :string
#  ordinal    :integer
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  invoice_id :bigint
#  usage_id   :bigint
#
# Indexes
#
#  index_invoice_parts_on_invoice_id  (invoice_id)
#  index_invoice_parts_on_usage_id    (usage_id)
#
# Foreign Keys
#
#  fk_rails_...  (invoice_id => invoices.id)
#  fk_rails_...  (usage_id => usages.id)
#

class InvoicePart < ApplicationRecord
  include Subtypeable
  include RankedModel

  belongs_to :invoice, inverse_of: :invoice_parts, touch: true
  belongs_to :usage, inverse_of: :invoice_parts, optional: true

  has_one :tarif, through: :usage
  has_one :booking, through: :usage

  attribute :apply, :boolean, default: true

  ranks :ordinal, with_same: :invoice_id, class_name: 'InvoicePart'

  scope :ordered, -> { rank(:ordinal) }

  validates :type, inclusion: { in: ->(_) { InvoicePart.subtypes.keys.map(&:to_s) } }

  before_validation do
    self.amount = amount&.floor(2) || 0
  end

  after_save do
    next unless amount_previously_changed?

    invoice.recalculate
    invoice.save if invoice.amount_changed?
  end

  def calculated_amount
    amount
  end

  def sum_of_predecessors
    invoice.invoice_parts.ordered.inject(0) do |sum, invoice_part|
      break sum if invoice_part == self

      invoice_part.to_sum(sum)
    end
  end

  def to_sum(sum)
    sum + calculated_amount
  end

  def self.from_usage(usage, **attributes)
    return unless usage

    I18n.with_locale(usage.booking.locale) do
      new(attributes.reverse_merge(
            usage: usage, label: usage.tarif.label, ordinal: usage.tarif.ordinal,
            breakdown: usage.remarks.presence || usage.breakdown, amount: usage.price
          ))
    end
  end

  class Filter < ApplicationFilter
    #   attribute :ref
    #   attribute :tenant
    #   attribute :homes, default: -> { [] }
    #   attribute :current_booking_states, default: -> { [] }
    #   attribute :previous_booking_states, default: -> { [] }
    #   attribute :booking_states, default: -> { [] }
    #   attribute :begins_at_after, :datetime
    #   attribute :begins_at_before, :datetime
    #   attribute :ends_at_after, :datetime
    #   attribute :ends_at_before, :datetime
    #   attribute :occupancy_type

    #   # Ensures backwards compatibilty
    #   def booking_states=(value)
    #     self.current_booking_states = value
    #   end

    #   def occupancy_filter
    #     @occupancy_filter ||= Occupancy::Filter.new({ begins_at_before: begins_at_before,
    #                                                   begins_at_after: begins_at_after,
    #                                                   ends_at_before: ends_at_before,
    #                                                   ends_at_after: ends_at_after })
    #   end

    #   filter :occupancy do |bookings|
    #     bookings.where(occupancy: occupancy_filter.apply(Occupancy.where.not(booking: nil)))
    #   end

    #   filter :occupancy_type do |bookings|
    #     bookings.joins(:occupancy).merge(Occupancy.where(occupancy_type: occupancy_type)) if occupancy_type.present?
    #   end

    #   filter :ref do |bookings|
    #     bookings.where(Booking.arel_table[:ref].matches("%#{ref.strip}%")) if ref.present?
    #   end

    #   filter :homes do |bookings|
    #     relevant_homes = homes.compact_blank
    #     bookings.where(home_id: relevant_homes) if relevant_homes.present?
    #   end

    #   filter :tenant do |bookings|
    #     next bookings if tenant.blank?

    #     bookings.joins(:tenant)
    #             .where(Tenant.arel_table[:search_cache].matches("%#{tenant}%")
    #         .or(Booking.arel_table[:tenant_organisation].matches("%#{tenant}%")))
    #   end

    #   filter :has_booking_state do |bookings|
    #     states = current_booking_states.compact_blank

    #     bookings.where(booking_state_cache: states) if states.any?
    #   end

    #   filter :had_booking_state do |bookings|
    #     states = previous_booking_states.compact_blank

    #     bookings.joins(:state_transitions).where(state_transitions: { to_state: states }) if states.any?
    #   end
    # end
  end
end
