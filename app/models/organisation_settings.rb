# frozen_string_literal: true

class OrganisationSettings < Settings
  attribute :tenant_birth_date_required, :boolean, default: true
  attribute :booking_window, DurationType.new, default: -> { 30.months }
  attribute :awaiting_contract_deadline, DurationType.new, default: -> { 10.days }
  attribute :overdue_request_deadline, DurationType.new, default: -> { 3.days }
  attribute :payment_overdue_deadline, DurationType.new, default: -> { 3.days }
  attribute :unconfirmed_request_deadline, DurationType.new, default: -> { 3.days }
  attribute :provisional_request_deadline, DurationType.new, default: -> { 10.days }
  attribute :last_minute_warning, DurationType.new, default: -> { 10.days }
  attribute :invoice_payment_deadline, DurationType.new, default: -> { 30.days }
  attribute :deposit_payment_deadline, DurationType.new, default: -> { 10.days }
  attribute :upcoming_soon_window, DurationType.new, default: -> { 14.days }
  attribute :deadline_postponable_for, DurationType.new, default: -> { 3.days }
  attribute :tentative_occupancy_color, :string, default: '#e8bc56'
  attribute :occupied_occupancy_color, :string, default: '#e85f5f' || '#f2a2a2'
  attribute :closed_occupancy_color, :string, default: '#929292'
  attribute :begins_at_default_time, DurationType.new, default: -> { 8.hours }
  attribute :ends_at_default_time, DurationType.new, default: -> { 3.days }
  attribute :default_calendar_view, :string, default: 'months'
  attribute :occupied_occupancy_states, array: true, default: lambda {
                                                                BookingStates.occupied_occupancy_able.keys.map(&:to_s)
                                                              }
  attribute :show_outbox, :boolean, default: false
  attribute :default_begins_at_time, :string
  attribute :default_ends_at_time, :string

  validates :tentative_occupancy_color, :occupied_occupancy_color,
            :closed_occupancy_color, format: { with: Occupancy::COLOR_REGEX }, allow_blank: true

  validates :default_begins_at_time, :default_ends_at_time, format: { with: /\A\d{2}:\d{2}\z/ }, allow_blank: true

  validates :booking_window, :awaiting_contract_deadline, :overdue_request_deadline,
            :unconfirmed_request_deadline, :provisional_request_deadline, :last_minute_warning,
            :invoice_payment_deadline, :deposit_payment_deadline, :deadline_postponable_for, :upcoming_soon_window,
            :payment_overdue_deadline,
            numericality: { less_than_or_equal: 5.years, greater_than_or_equal: 0 }

  def occupancy_colors
    {
      tentative: tentative_occupancy_color,
      occupied: occupied_occupancy_color,
      closed: closed_occupancy_color
    }.tap { |hash| hash.default = '#FFFFFF00' }
  end
end
