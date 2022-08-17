# frozen_string_literal: true

# == Schema Information
#
# Table name: bookings
#
#  id                     :uuid             not null, primary key
#  accept_conditions      :boolean          default(FALSE)
#  approximate_headcount  :integer
#  booking_flow_type      :string
#  booking_state_cache    :string           default("initial"), not null
#  cancellation_reason    :text
#  color                  :string
#  committed_request      :boolean
#  concluded              :boolean          default(FALSE)
#  conditions_accepted_at :datetime
#  editable               :boolean          default(TRUE)
#  email                  :string
#  import_data            :jsonb
#  internal_remarks       :text
#  invoice_address        :text
#  locale                 :string
#  notifications_enabled  :boolean          default(FALSE)
#  purpose_description    :string
#  ref                    :string
#  remarks                :text
#  state_data             :json
#  tenant_organisation    :string
#  token                  :string
#  usages_entered         :boolean          default(FALSE)
#  usages_presumed        :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  booking_category_id    :integer
#  deadline_id            :bigint
#  home_id                :bigint           not null
#  organisation_id        :bigint           not null
#  tenant_id              :integer
#
# Indexes
#
#  index_bookings_on_booking_state_cache  (booking_state_cache)
#  index_bookings_on_deadline_id          (deadline_id)
#  index_bookings_on_home_id              (home_id)
#  index_bookings_on_locale               (locale)
#  index_bookings_on_organisation_id      (organisation_id)
#  index_bookings_on_ref                  (ref)
#  index_bookings_on_token                (token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#

class Booking < ApplicationRecord
  include BookingStateConcern

  DEFAULT_INCLUDES = [:organisation, :home, :state_transitions, :invoices, :contracts, :payments, :booking_agent,
                      :category, :booked_extras, :logs,
                      { tenant: :organisation, deadline: :booking, occupancy: :home,
                        agent_booking: %i[booking_agent organisation home] }].freeze

  belongs_to :organisation, inverse_of: :bookings
  belongs_to :home, inverse_of: :bookings
  belongs_to :tenant, inverse_of: :bookings, optional: true
  belongs_to :deadline, inverse_of: :booking, optional: true
  belongs_to :category, inverse_of: :bookings, class_name: 'BookingCategory', optional: true,
                        foreign_key: :booking_category_id

  has_many :invoices, dependent: :destroy, autosave: false
  has_many :payments, dependent: :destroy, autosave: false
  has_many :booking_copy_tarifs, dependent: :destroy, class_name: 'Tarif'
  has_many :transitive_tarifs, through: :home, class_name: 'Tarif', source: :tarifs
  has_many :notifications, dependent: :destroy, inverse_of: :booking, autosave: true, validate: false
  has_many :usages, -> { ordered }, dependent: :destroy, inverse_of: :booking
  has_many :contracts, -> { ordered }, dependent: :destroy, autosave: false, inverse_of: :booking
  has_many :offers, -> { ordered }, dependent: :destroy, autosave: false, inverse_of: :booking
  has_many :used_tarifs, through: :usages, class_name: 'Tarif', source: :tarif, inverse_of: :booking
  has_many :deadlines, dependent: :delete_all, inverse_of: :booking
  has_many :state_transitions, dependent: :delete_all, autosave: false
  has_many :operator_responsibilities, inverse_of: :booking, dependent: :destroy
  has_many :booked_extras, inverse_of: :booking, dependent: :destroy
  has_many :bookable_extras, through: :booked_extras
  has_many :logs, inverse_of: :booking, dependent: :destroy

  has_one  :occupancy, inverse_of: :booking, dependent: :destroy, validate: true
  has_one  :agent_booking, dependent: :destroy, inverse_of: :booking
  has_one  :booking_agent, through: :agent_booking
  has_one_attached :usage_report

  has_secure_token :token, length: 48

  validates :email, format: Devise.email_regexp, presence: true, on: %i[public_update public_create]
  validates :accept_conditions, acceptance: true, on: :public_create
  validates :category, :tenant, presence: true, on: :public_update
  validates :committed_request, inclusion: { in: [true, false] }, on: :public_update
  validates :approximate_headcount, numericality: { greater_than: 0 }, on: :public_update
  validates :invoice_address, length: { maximum: 255 }
  validates :tenant_organisation, :purpose_description, length: { maximum: 150 }
  validates :purpose_description, presence: true, on: :public_update

  validate(on: %i[public_create public_update]) do
    next errors.add(:base, :conflicting) if occupancy.conflicting.present?
    next if home.blank? || occupancy.conflicting(home.settings.booking_margin).blank?

    errors.add(:base, :booking_margin_too_small, margin: home.settings.booking_margin&.in_minutes&.to_i)
  end

  scope :ordered, -> { joins(:occupancy).order(Occupancy.arel_table[:begins_at]) }
  scope :with_default_includes, -> { includes(DEFAULT_INCLUDES) }
  scope :inconcluded, -> { where(concluded: false) }

  before_validation :organisation, :occupancy, :set_tenant
  before_create :set_ref
  after_create :reload

  accepts_nested_attributes_for :occupancy, reject_if: :all_blank, update_only: true
  accepts_nested_attributes_for :tenant, update_only: true, reject_if: :reject_tenant_attributes?
  accepts_nested_attributes_for :usages, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :agent_booking, reject_if: :all_blank, update_only: true

  delegate :to_s, to: :ref
  delegate :exceeded?, to: :deadline, prefix: true, allow_nil: true

  def overnight_stays
    occupancy.nights * approximate_headcount
  end

  def actual_overnight_stays
    usages.filter_map { |usage| usage.tarif.is_a?(Tarifs::OvernightStay) && usage.used_units }.compact.sum
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

  def agent_booking?
    agent_booking.present?
  end

  def operators_for(*responsibilities)
    responsibilities.map do |responsibility|
      operator_responsibilities.where(responsibility: responsibility).first
    end.compact.uniq
  end

  def cache_key
    "#{super}@#{updated_at.iso8601(3)}"
  end

  def update_deadline!
    deadlines.reload && update(deadline: deadlines.next.take)
  end

  def to_liquid
    Manage::BookingSerializer.render_as_hash(self).deep_stringify_keys
  end

  def invoice_address_lines
    @invoice_address_lines ||= invoice_address&.lines&.reject(&:blank?).presence || tenant&.full_address_lines
  end

  def email
    super.presence || tenant&.email.presence
  end

  def set_tenant
    return if email.blank? || tenant&.email.present?

    self.tenant = Tenant.find_or_initialize_by(email: email, organisation: organisation)
  end

  def build_tenant(attributes = {})
    super(attributes.merge(organisation: organisation || attributes[:organisation]))
  end

  def occupancy
    super || self.occupancy = build_occupancy(booking: self, home: home)
  end

  def organisation
    super || self.organisation = home&.organisation
  end

  # def save(...)
  #   super(...)
  # rescue ActiveRecord::NotNullViolation
  #   binding.pry
  # end

  private

  def reject_tenant_attributes?(tenant_attributes)
    (tenant_id_changed? && tenant_id_was.present?) ||
      tenant_attributes.slice(:email, :first_name, :last_name, :street_address, :zipcode, :city).values.all?(&:blank?)
  end

  def set_ref
    self.ref ||= BookingRefService.new.generate(self)
  end
end
