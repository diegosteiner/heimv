# frozen_string_literal: true

class HomeSettings < Settings
  attribute :booking_window, DurationType.new, default: -> { 30.months }
  attribute :awaiting_contract_deadline, DurationType.new, default: -> { 10.days }
  attribute :overdue_request_deadline, DurationType.new, default: -> { 3.days }
  attribute :unconfirmed_request_deadline, DurationType.new, default: -> { 3.days }
  attribute :provisional_request_deadline, DurationType.new, default: -> { 10.days }
  attribute :last_minute_warning, DurationType.new, default: -> { 10.days }
  attribute :invoice_payment_deadline, DurationType.new, default: -> { 30.days }
  attribute :deposit_payment_deadline, DurationType.new, default: -> { 10.days }
  attribute :upcoming_soon_window, DurationType.new, default: -> { 14.days }
  attribute :deadline_postponable_for, DurationType.new, default: -> { 3.days }
  attribute :booking_margin, DurationType.new, default: 0
  attribute :min_occupation, :integer, default: 0
  attribute :tentative_occupancy_color, :string, default: '#e8bc56'
  attribute :occupied_occupancy_color, :string, default: '#e85f5f' || '#f2a2a2'
  attribute :closed_occupancy_color, :string, default: '#929292'

  validates :booking_margin, :booking_window, :awaiting_contract_deadline, :overdue_request_deadline,
            :unconfirmed_request_deadline, :provisional_request_deadline, :last_minute_warning,
            :invoice_payment_deadline, :deposit_payment_deadline, :deadline_postponable_for, :upcoming_soon_window,
            :booking_window, numericality: { less_than_or_equal: 5.years, greater_than_or_equal: 0 }
  validates :tentative_occupancy_color, :occupied_occupancy_color,
            :closed_occupancy_color, format: { with: Occupancy::COLOR_REGEX }, allow_nil: true

  def occupancy_color(occupancy)
    {
      tentative: tentative_occupancy_color,
      occupied: occupied_occupancy_color,
      closed: closed_occupancy_color
    }.fetch(occupancy&.occupancy_type&.to_sym, '#FFFFFF00')
  end
end
