# frozen_string_literal: true

# == Schema Information
#
# Table name: bookings
#
#  id                    :uuid             not null, primary key
#  approximate_headcount :integer
#  booking_flow_type     :string
#  booking_state_cache   :string           default("initial"), not null
#  cancellation_reason   :text
#  committed_request     :boolean
#  concluded             :boolean          default(FALSE)
#  editable              :boolean          default(TRUE)
#  email                 :string
#  import_data           :jsonb
#  internal_remarks      :text
#  invoice_address       :text
#  locale                :string
#  notifications_enabled :boolean          default(FALSE)
#  purpose_key           :string
#  ref                   :string
#  remarks               :text
#  state_data            :json
#  tenant_organisation   :string
#  timeframe_locked      :boolean          default(FALSE)
#  usages_entered        :boolean          default(FALSE)
#  usages_presumed       :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  deadline_id           :bigint
#  home_id               :bigint           not null
#  organisation_id       :bigint           not null
#  purpose_id            :integer
#  tenant_id             :integer
#
# Indexes
#
#  index_bookings_on_booking_state_cache  (booking_state_cache)
#  index_bookings_on_deadline_id          (deadline_id)
#  index_bookings_on_home_id              (home_id)
#  index_bookings_on_locale               (locale)
#  index_bookings_on_organisation_id      (organisation_id)
#  index_bookings_on_ref                  (ref)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

class Booking < ApplicationRecord
  include BookingStateConcern

  DEFAULT_INCLUDES = [:organisation, :home, :booking_transitions, :invoices, :contracts, :payments, :booking_agent,
                      :purpose, { tenant: :organisation, deadline: :booking, occupancy: :home,
                                  agent_booking: %i[booking_agent organisation home] }].freeze

  belongs_to :organisation, inverse_of: :bookings
  belongs_to :home, inverse_of: :bookings
  belongs_to :tenant, inverse_of: :bookings, optional: true
  belongs_to :deadline, inverse_of: :booking, optional: true
  belongs_to :purpose, inverse_of: :bookings, class_name: 'BookingPurpose', optional: true

  has_many :invoices, dependent: :destroy, autosave: false
  has_many :payments, dependent: :destroy, autosave: false
  has_many :booking_copy_tarifs, dependent: :destroy, class_name: 'Tarif'
  has_many :notifications, dependent: :destroy, inverse_of: :booking, autosave: true, validate: false
  has_many :applicable_tarifs, ->(booking) { Tarif.applicable_to(booking) }, class_name: 'Tarif', inverse_of: :booking
  has_many :usages, -> { ordered }, dependent: :destroy, inverse_of: :booking
  has_many :contracts, -> { ordered }, dependent: :destroy, autosave: false, inverse_of: :booking
  has_many :offers, -> { ordered }, dependent: :destroy, autosave: false, inverse_of: :booking
  has_many :used_tarifs, through: :usages, class_name: 'Tarif', source: :tarif, inverse_of: :booking
  has_many :transitive_tarifs, through: :home, class_name: 'Tarif', source: :tarif
  has_many :deadlines, dependent: :delete_all, inverse_of: :booking
  has_many :booking_transitions, dependent: :delete_all, autosave: false

  has_one :occupancy, inverse_of: :booking, dependent: :destroy
  has_one  :agent_booking, dependent: :destroy, inverse_of: :booking
  has_one  :booking_agent, through: :agent_booking

  attribute :accept_conditions, default: false
  enum locale: I18n.available_locales.index_by(&:itself)

  validates :email, format: Devise.email_regexp, presence: true, on: %i[public_update public_create]
  validates :accept_conditions, acceptance: true, on: :public_create
  validates :purpose, :tenant, presence: true, on: :public_update
  validates :committed_request, inclusion: { in: [true, false] }, on: :public_update
  validates :approximate_headcount, numericality: { greater_than: 0 }, on: :public_update
  validates :invoice_address, length: { maximum: 255 }

  validate(on: %i[public_create public_update]) do
    next errors.add(:base, :conflicting) if occupancy.conflicting.present?

    if occupancy.conflicting(home.booking_margin).present?
      errors.add(:base, :booking_margin_too_small, margin: home.booking_margin)
    end
  end

  scope :ordered, -> { joins(:occupancy).order(Occupancy.arel_table[:begins_at]) }
  scope :with_default_includes, -> { includes(DEFAULT_INCLUDES) }
  scope :inconcluded, -> { where(concluded: false) }

  before_validation :set_organisation, :set_occupancy_attributes, :set_tenant_attributes
  before_create :set_ref
  after_create :reload

  accepts_nested_attributes_for :occupancy, reject_if: :reject_occupancy_attributes?, update_only: true
  accepts_nested_attributes_for :tenant, update_only: true, reject_if: :reject_tentant_attributes?
  accepts_nested_attributes_for :usages, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :agent_booking, reject_if: :all_blank, update_only: true

  delegate :to_s, to: :ref

  def overnight_stays
    occupancy.nights * approximate_headcount
  end

  def concluded!
    # rubocop:disable Rails/SkipsModelValidations
    update_columns(concluded: true, timeframe_locked: true, editable: false)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def contract
    contracts.valid.last
  end

  def deadline_exceeded?
    deadline&.exceeded?
  end

  def agent_booking?
    agent_booking.present?
  end

  def cache_key
    [super, updated_at.to_i].join('-')
  end

  def update_deadline!
    deadlines.reload && update(deadline: deadlines.next.take)
  end

  def to_liquid
    Manage::BookingSerializer.render_as_hash(self).deep_stringify_keys
  end

  def locale
    super || I18n.locale || I18n.default_locale
  end

  def invoice_address_lines
    @invoice_address_lines ||= invoice_address&.lines&.reject(&:blank?).presence || tenant&.full_address_lines
  end

  private

  def reject_tentant_attributes?(tenant_attributes)
    tenant_id_changed? && tenant_id_was.present? ||
      tenant_attributes.slice(:email, :first_name, :last_name, :street_address, :zipcode, :city).values.all?(&:blank?)
  end

  def reject_occupancy_attributes?(occupancy_attributes)
    occupancy_attributes.values.all?(&:blank?) || timeframe_locked?
  end

  def set_tenant_attributes
    return unless tenant || email.presence

    self.tenant ||= organisation.tenants.find_or_initialize_by(email: email)
    self.tenant.email = email
    self.tenant.organisation = organisation
  end

  def set_occupancy_attributes
    self.occupancy ||= build_occupancy
    occupancy.home = home
    occupancy.booking = self
    occupancy
  end

  def set_ref
    self.ref ||= BookingRefService.new.generate(self)
  end

  def set_organisation
    self.organisation ||= home&.organisation
  end
end
