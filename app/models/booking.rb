# frozen_string_literal: true

# == Schema Information
#
# Table name: bookings
#
#  id                     :uuid             not null, primary key
#  accept_conditions      :boolean          default(FALSE)
#  approximate_headcount  :integer
#  begins_at              :datetime
#  booking_flow_type      :string
#  booking_state_cache    :string           default("initial"), not null
#  cancellation_reason    :text
#  committed_request      :boolean
#  concluded              :boolean          default(FALSE)
#  conditions_accepted_at :datetime
#  editable               :boolean          default(TRUE)
#  email                  :string
#  ends_at                :datetime
#  import_data            :jsonb
#  internal_remarks       :text
#  invoice_address        :text
#  locale                 :string
#  notifications_enabled  :boolean          default(FALSE)
#  occupancy_color        :string
#  occupancy_type         :integer          default("free"), not null
#  purpose_description    :string
#  ref                    :string
#  remarks                :text
#  state_data             :json
#  tenant_organisation    :string
#  token                  :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  booking_category_id    :integer
#  deadline_id            :bigint
#  organisation_id        :bigint           not null
#  tenant_id              :integer
#
# Indexes
#
#  index_bookings_on_booking_state_cache  (booking_state_cache)
#  index_bookings_on_deadline_id          (deadline_id)
#  index_bookings_on_locale               (locale)
#  index_bookings_on_organisation_id      (organisation_id)
#  index_bookings_on_ref                  (ref)
#  index_bookings_on_token                (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

class Booking < ApplicationRecord
  include BookingStateConcern
  include Timespanable

  DEFAULT_INCLUDES = [:organisation, :state_transitions, :invoices, :contracts, :payments, :booking_agent,
                      :category, :booked_extras, :logs,
                      { tenant: :organisation, deadline: :booking, occupancies: :home,
                        agent_booking: %i[booking_agent organisation] }].freeze

  belongs_to :organisation, inverse_of: :bookings
  belongs_to :tenant, inverse_of: :bookings, optional: true
  belongs_to :deadline, inverse_of: :booking, optional: true
  belongs_to :category, inverse_of: :bookings, class_name: 'BookingCategory', optional: true,
                        foreign_key: :booking_category_id

  has_many :invoices, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :notifications, dependent: :destroy, inverse_of: :booking, autosave: true, validate: false
  has_many :usages, -> { ordered }, dependent: :destroy, inverse_of: :booking
  has_many :tarifs, through: :usages, inverse_of: :bookings
  has_many :contracts, -> { ordered }, dependent: :destroy, inverse_of: :booking
  has_many :deadlines, dependent: :delete_all, inverse_of: :booking
  has_many :state_transitions, dependent: :delete_all
  has_many :operator_responsibilities, inverse_of: :booking, dependent: :destroy
  has_many :booked_extras, inverse_of: :booking, dependent: :destroy
  has_many :bookable_extras, through: :booked_extras
  has_many :logs, inverse_of: :booking, dependent: :destroy

  has_one  :agent_booking, dependent: :destroy, inverse_of: :booking
  has_one  :booking_agent, through: :agent_booking
  has_one_attached :usage_report

  has_many :occupancies, inverse_of: :booking, dependent: :destroy, autosave: true
  has_many :homes, through: :occupancies

  timespan :begins_at, :ends_at
  has_secure_token :token, length: 48
  enum occupancy_type: Occupancy::OCCUPANCY_TYPES

  validates :email, format: Devise.email_regexp, presence: true, on: %i[public_update public_create]
  validates :home_ids, presence: true, on: %i[public_update public_create]
  validates :accept_conditions, acceptance: true, on: :public_create
  validates :category, :tenant, presence: true, on: :public_update
  validates :committed_request, inclusion: { in: [true, false] }, on: :public_update
  validates :approximate_headcount, numericality: { greater_than: 0 }, on: :public_update
  validates :invoice_address, length: { maximum: 255 }
  validates :tenant_organisation, :purpose_description, length: { maximum: 150 }
  validates :purpose_description, presence: true, on: :public_update
  validates :occupancy_color, format: { with: Occupancy::COLOR_REGEX }, allow_blank: true

  validate(on: %i[public_create public_update]) do
    next errors.add(:base, :conflicting) if conflicting_occupancies(0).any?

    margin = organisation.settings.booking_margin
    next if margin.zero? || conflicting_occupancies(margin).none?

    errors.add(:base, :booking_margin_too_small, margin: margin&.in_minutes&.to_i)
  end

  scope :ordered, -> { order(begins_at: :ASC) }
  scope :with_default_includes, -> { includes(DEFAULT_INCLUDES) }

  before_validation :set_tenant, :update_occupancies
  before_create :set_ref

  accepts_nested_attributes_for :tenant, update_only: true, reject_if: :reject_tenant_attributes?
  accepts_nested_attributes_for :usages, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :agent_booking, reject_if: :all_blank, update_only: true

  delegate :to_s, to: :ref
  delegate :exceeded?, to: :deadline, prefix: true, allow_nil: true

  def overnight_stays
    return unless begins_at.present? && ends_at.present?

    nights = (ends_at.to_date - begins_at.to_date).to_i
    nights * approximate_headcount
  end

  def conflicting_occupancies(margin = 0)
    occupancies.map { _1.conflicting(margin) }.flatten.compact
  end

  def conclude
    update!(concluded: true, editable: false)
  end

  def locale
    tenant&.locale&.presence || organisation.locale
  end

  def contract
    contracts.valid.last
  end

  def cache_key
    "#{super}@#{updated_at.iso8601(3)}"
  end

  def update_deadline!
    deadlines.reload && update(deadline: deadlines.next.take)
  end

  def update_occupancies
    occupancies.each(&:update_from_booking)
  end

  def invoice_address_lines
    @invoice_address_lines ||= invoice_address&.lines&.reject(&:blank?).presence || tenant&.full_address_lines
  end

  def email
    super.presence || tenant&.email.presence
  end

  def email=(value)
    super(value&.downcase)
  end

  def set_tenant
    return if email.blank? || tenant&.email.present?

    self.tenant = Tenant.find_or_initialize_by(email: email, organisation: organisation)
  end

  def build_tenant(attributes = {})
    super(attributes.merge(organisation: organisation || attributes[:organisation]))
  end

  def override_occupancy_color?
    self[:occupancy_color].present?
  end

  def occupancy_color
    super.presence || organisation&.settings&.occupancy_colors&.[](occupancy_type&.to_sym)
  end

  def responsibilities
    @responsibilities ||= operator_responsibilities.group_by(&:responsibility)
                                                   .transform_values(&:first)
                                                   .symbolize_keys
  end

  def home
    raise 'Deprecated call to home' if homes.many?

    homes.first
  end

  private

  def reject_tenant_attributes?(tenant_attributes)
    (tenant_id_changed? && tenant_id_was.present?) ||
      tenant_attributes.slice(:email, :first_name, :last_name, :street_address, :zipcode, :city).values.all?(&:blank?)
  end

  def set_ref
    self.ref ||= BookingRefService.new.generate(self)
  end
end
