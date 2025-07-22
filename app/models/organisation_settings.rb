# frozen_string_literal: true

class OrganisationSettings
  include StoreModel::Model
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  attribute :default_calendar_view, :string, default: 'months' # store as user preference only

  attribute :tenant_birth_date_required, :boolean, default: true
  attribute :contract_sign_by_click_enabled, :boolean, default: false
  attribute :invoice_show_usage_details, :boolean, default: true
  attribute :booking_window, DurationType.new, default: -> { 30.months }
  attribute :last_minute_warning, DurationType.new, default: -> { 10.days }
  attribute :upcoming_soon_window, DurationType.new, default: -> { 14.days }
  attribute :tentative_occupancy_color, :string, default: '#e8bc56'
  attribute :occupied_occupancy_color, :string, default: '#e85f5f' || '#f2a2a2'
  attribute :closed_occupancy_color, :string, default: '#929292'
  attribute :default_begins_at_time, :string, default: -> { '08:00' }
  attribute :default_ends_at_time, :string, default: -> { '16:00' }
  attribute :locales, array: true, default: -> { I18n.available_locales.map(&:to_s) }
  attribute :predefined_salutation_form, :string
  attribute :available_begins_at_times, array: true, default: -> { available_times(hours: 8..22) }
  attribute :available_ends_at_times, array: true, default: -> { available_times(hours: 8..22) }

  validates :tentative_occupancy_color, :occupied_occupancy_color,
            :closed_occupancy_color, format: { with: Occupancy::COLOR_REGEX }, allow_blank: true

  validates :default_begins_at_time, :default_ends_at_time, format: { with: /\A\d{2}:\d{2}\z/ }, allow_blank: true

  validates :booking_window, :last_minute_warning, :upcoming_soon_window,
            numericality: { less_than_or_equal: 5.years, greater_than_or_equal: 0 }

  validates :predefined_salutation_form, inclusion: { in: Tenant.salutation_forms.keys.map(&:to_s) }, allow_blank: true
  validate do
    errors.add(:available_ends_at_times, :invalid) unless available_ends_at_times&.compact_blank&.all? do
      self.class.available_times.include?(it)
    end
    errors.add(:available_begins_at_times, :invalid) unless available_begins_at_times&.compact_blank&.all? do
      self.class.available_times.include?(it)
    end
  end

  def occupancy_colors
    {
      tentative: tentative_occupancy_color,
      occupied: occupied_occupancy_color,
      closed: closed_occupancy_color
    }.tap { |hash| hash.default = '#FFFFFF00' }
  end

  def self.available_times(hours: 0..23, minutes: [0, 15, 30, 45])
    hours.flat_map { |hour| minutes.map { |minute| format('%<hour>02d:%<minute>02d', hour:, minute:) } }
  end
end
