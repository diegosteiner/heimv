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
#  booking_questions      :jsonb
#  booking_state_cache    :string           default("initial"), not null
#  cancellation_reason    :text
#  committed_request      :boolean
#  concluded              :boolean          default(FALSE)
#  conditions_accepted_at :datetime
#  editable               :boolean
#  email                  :string
#  ends_at                :datetime
#  ignore_conflicting     :boolean          default(FALSE), not null
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
#  sequence_number        :integer
#  sequence_year          :integer
#  state_data             :json
#  tenant_organisation    :string
#  token                  :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  booking_category_id    :integer
#  home_id                :integer          not null
#  organisation_id        :bigint           not null
#  tenant_id              :integer
#

class Booking < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include Timespanable
  include Statesman::Adapters::ActiveRecordQueries[transition_class: Booking::StateTransition,
                                                   initial_state: :initial,
                                                   transition_name: :state_transition]

  VALIDATION_CONTEXTS = %i[public_create public_update agent_create agent_update manage_create manage_update].freeze
  ROLES = (%i[organisation tenant booking_agent] + OperatorResponsibility::RESPONSIBILITIES.keys).freeze
  DEFAULT_INCLUDES = [:organisation, :state_transitions, :invoices, :contracts, :payments, :booking_agent,
                      :category, :logs, :home,
                      { tenant: :organisation, deadline: :booking, occupancies: :occupiable,
                        agent_booking: %i[booking_agent organisation],
                        booking_question_responses: :booking_question }].freeze

  belongs_to :home
  belongs_to :organisation, inverse_of: :bookings
  belongs_to :tenant, inverse_of: :bookings, autosave: true
  belongs_to :category, inverse_of: :bookings, class_name: 'BookingCategory', optional: true,
                        foreign_key: :booking_category_id

  has_many :invoices, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :notifications, dependent: :destroy, inverse_of: :booking, autosave: true, validate: false
  has_many :usages, -> { ordered }, dependent: :destroy, inverse_of: :booking
  has_many :tarifs, through: :usages, inverse_of: :bookings
  has_many :contracts, -> { ordered }, dependent: :destroy, inverse_of: :booking
  has_many :state_transitions, dependent: :delete_all
  has_many :operator_responsibilities, inverse_of: :booking, dependent: :destroy
  has_many :logs, inverse_of: :booking, dependent: :destroy
  has_many :occupancies, inverse_of: :booking, dependent: :destroy, autosave: true
  has_many :occupiables, through: :occupancies
  has_many :booking_question_responses, -> { ordered }, dependent: :destroy, autosave: true, inverse_of: :booking
  has_many :booking_questions, through: :booking_question_responses

  has_one  :deadline, inverse_of: :booking, dependent: :destroy
  has_one  :agent_booking, dependent: :destroy, inverse_of: :booking
  has_one  :booking_agent, through: :agent_booking

  has_one_attached :usage_report
  has_secure_token :token, length: 48
  attr_accessor :transition_to, :skip_infer_transitions, :applied_transitions

  timespan :begins_at, :ends_at
  enum :occupancy_type, Occupancy::OCCUPANCY_TYPES
  normalizes :email, with: ->(email) { email.present? ? EmailAddress.normal(email) : nil }

  validates :invoice_address, length: { maximum: 255 }
  validates :tenant_organisation, :purpose_description, length: { maximum: 150 }
  validates :approximate_headcount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :occupancy_color, format: { with: Occupancy::COLOR_REGEX }, allow_nil: true
  validates :email, presence: true, on: %i[public_update public_create]
  validates :approximate_headcount, :purpose_description, presence: true, on: :public_update
  validates :category, presence: true, on: %i[public_update agent_update]
  validates :committed_request, inclusion: { in: [true, false] }, on: :public_update
  validates :locale, inclusion: { in: ->(booking) { booking.organisation.locales } }, on: :public_update
  validate do
    errors.add(:occupiable_ids, :blank) if occupancies.none?
    errors.add(:email, :invalid) unless email.nil? || EmailAddress.valid?(email)
    organisation&.booking_validations&.each do |validation|
      validation.booking_valid?(self, validation_context:) || errors.add(:base, validation.error_message)
    end
  end
  validate on: %i[agent_create agent_update] do
    errors.add(:occupiable_ids, :occupancy_conflict) if conflicting?(%i[occupied tentative])
  end

  validate on: %i[public_create public_update] do
    next if organisation.booking_state_settings.enable_waitlist && !conflicting?
    next if !organisation.booking_state_settings.enable_waitlist && !conflicting?(%i[occupied tentative])

    errors.add(:occupiable_ids, :occupancy_conflict)
  end

  validate on: %i[public_create public_update agent_update] do
    window = organisation.settings.booking_window
    errors.add(:begins_at, :too_far_in_future) if begins_at_changed? && window && begins_at&.>(window.from_now)
  end

  scope :ordered, -> { order(begins_at: :ASC) }
  scope :with_default_includes, -> { includes(DEFAULT_INCLUDES) }

  before_validation :update_occupancies, :assert_tenant!
  before_save :sequence_number
  before_create :generate_ref
  after_save :apply_transitions
  after_touch :apply_transitions

  accepts_nested_attributes_for :tenant, update_only: true, reject_if: :reject_tenant_attributes?
  accepts_nested_attributes_for :usages, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :agent_booking, reject_if: :all_blank, update_only: true
  accepts_nested_attributes_for :booking_question_responses, reject_if: :all_blank, update_only: true

  delegate :to_s, to: :ref
  delegate :can_transition_to?, :in_state?, :booking_state, to: :booking_flow, allow_nil: true

  def overnight_stays
    return unless begins_at.present? && ends_at.present?

    nights = (ends_at.to_date - begins_at.to_date).to_i
    nights * approximate_headcount
  end

  def conclude
    update!(concluded: true)
  end

  def locale
    tenant&.locale.presence || super.presence
  end

  def contract
    contracts.valid.last
  end

  def cache_key
    "#{super}@#{updated_at.iso8601(3)}"
  end

  def update_occupancies
    occupancies.each(&:update_from_booking)
  end

  def email
    super || tenant&.email
  end

  def tenant
    super || @tenant ||= find_existing_tenant(current_tenant: nil)
  end

  def find_existing_tenant(current_tenant: tenant)
    return current_tenant if current_tenant&.persisted? && current_tenant.valid? &&
                             current_tenant.email == self[:email]

    Tenant.find_by(email: self[:email], organisation:) unless organisation.blank? || self[:email].blank?
  end

  def assert_tenant!
    self.tenant = find_existing_tenant&.merge_with_new(tenant) ||
                  tenant || build_tenant(email: self[:email], organisation:, locale:)

    tenant.organisation = organisation
    tenant.email ||= self[:email]
  end

  def occupancy_color
    super.presence || organisation&.settings&.occupancy_colors&.[](occupancy_type&.to_sym)
  end

  def roles
    @roles ||= { administration: organisation, tenant:, booking_agent: agent_booking&.booking_agent }.merge(
      operator_responsibilities.group_by(&:responsibility).transform_values(&:first)
    ).symbolize_keys.compact_blank
  end

  def editable?
    return editable unless editable.nil?

    booking_state&.editable || false
  end

  def sequence_number
    self[:sequence_number] ||= organisation.key_sequences.key(self.class.sti_name, year: sequence_year).lease!
  end

  def sequence_year
    self[:sequence_year] ||= begins_at.year
  end

  def generate_ref(force: false)
    self.ref = RefBuilders::Booking.new(self).generate if ref.blank? || force
  end

  def apply_transitions(transitions = transition_to, metadata: nil, infer_transitions: !skip_infer_transitions)
    self.applied_transitions = Array.wrap(transitions).compact_blank.map do |transition|
      next transition if can_transition_to?(transition) && booking_flow.transition_to(transition, metadata:)

      errors.add(:transition_to, :invalid_transition, transition:)
      return false
    end
    self.transition_to = nil
    self.applied_transitions += booking_flow.infer if infer_transitions
    update_booking_state_cache!
    applied_transitions
  end

  def update_booking_state_cache!
    return unless booking_state_cache != booking_state&.to_s

    update_columns(booking_state_cache: booking_state.to_s, updated_at: Time.zone.now) # rubocop:disable Rails/SkipsModelValidations
  end

  def conflicting?(conflicting_occupancy_types = %i[occupied])
    occupancies.any? { it.conflicting(conflicting_occupancy_types)&.exists? }
  end

  def booking_flow_class
    @booking_flow_class ||= (booking_flow_type && BookingFlows.const_get(booking_flow_type).new) ||
                            organisation&.booking_flow_class
  end

  def booking_flow
    @booking_flow ||= booking_flow_class&.new(self)
  end

  private

  def reject_tenant_attributes?(tenant_attributes)
    (tenant_id_changed? && tenant_id_was.present?) ||
      tenant_attributes.slice(:email, :first_name, :last_name, :street_address, :zipcode, :city).values.all?(&:blank?)
  end
end
