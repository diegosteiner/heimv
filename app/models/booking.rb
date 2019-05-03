# == Schema Information
#
# Table name: bookings
#
#  id                    :uuid             not null, primary key
#  home_id               :bigint(8)        not null
#  state                 :string           default("initial"), not null
#  tenant_organisation          :string
#  email                 :string
#  tenant_id             :integer
#  state_data            :json
#  committed_request     :boolean
#  cancellation_reason   :text
#  approximate_headcount :integer
#  remarks               :text
#  invoice_address       :text
#  purpose               :string
#  ref                   :string
#  editable              :boolean          default(TRUE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  booking_agent_code    :string
#

class Booking < ApplicationRecord
  include BookingState
  include Statesman::Adapters::ActiveRecordQueries
  DEFAULT_INCLUDES = %i[occupancy tenant home booking_transitions invoices contracts deadlines payments messages].freeze

  belongs_to :home,          inverse_of: :bookings
  belongs_to :tenant,        inverse_of: :bookings, optional: true
  belongs_to :booking_agent, inverse_of: :bookings, optional: true,
                             foreign_key: :booking_agent_code, primary_key: :code

  has_one  :occupancy,       dependent: :destroy, inverse_of: :booking, autosave: true

  has_many :invoices,            dependent: :destroy, autosave: false
  has_many :payments,            dependent: :destroy, autosave: false
  has_many :usages,              dependent: :destroy # , autosave: false
  has_many :booking_copy_tarifs, dependent: :destroy, class_name: 'Tarif'
  has_many :deadlines,           dependent: :destroy, inverse_of: :booking
  has_many :messages,            dependent: :destroy, inverse_of: :booking

  has_many :applicable_tarifs, ->(booking) { Tarif.applicable_to(booking) }, class_name: 'Tarif', inverse_of: :booking
  has_many :contracts,         -> { ordered }, dependent: :destroy, autosave: false, inverse_of: :booking
  has_many :used_tarifs,       through: :usages, class_name: 'Tarif', source: :tarif, inverse_of: :booking
  has_many :transitive_tarifs, through: :home, class_name: 'Tarif', source: :tarif

  validates :home, :occupancy, presence: true
  validates :email, format: Devise.email_regexp, presence: true, unless: :booking_agent_responsible?

  validates :accept_conditions, acceptance: true,                 on: :public_create
  validates :tenant, presence: true,                              on: :public_update
  validates :committed_request, inclusion: { in: [true, false] }, on: :public_update
  validates :purpose, presence: true,                             on: :public_update
  validates :approximate_headcount, numericality: true,           on: :public_update

  validate(on: %i[public_create public_update]) do
    errors.add(:base, :conflicting) if occupancy.conflicting.any?
  end

  scope :ordered, -> { order(created_at: :ASC) }
  scope :with_default_includes, -> { includes(DEFAULT_INCLUDES) }

  before_validation :set_occupancy_attributes
  before_validation :assign_tenant_from_email
  before_create     :set_ref
  after_create      :reload

  accepts_nested_attributes_for :occupancy, reject_if: :all_blank, update_only: true
  accepts_nested_attributes_for :tenant, reject_if: :all_blank, update_only: true
  accepts_nested_attributes_for :usages, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :deadlines, reject_if: :all_blank, update_only: true

  attribute :accept_conditions, default: false
  # enum purpose: { camp: :camp, event: :event }

  def to_s
    ref
  end

  def correspondence_email
    tenant&.email&.presence || self[:email]&.presence || booking_agent&.email
  end

  def overnight_stays
    occupancy.nights * approximate_headcount
  end

  def editable!(value = true)
    # rubocop:disable Rails/SkipsModelValidations
    update_columns(editable: value)
    # rubocop:enable Rails/SkipsModelValidations
  end

  def self.strategy
    @strategy ||= BookingStrategies::Default.new
  end

  def self.transition_class
    BookingTransition
  end

  def contract
    contracts.valid.last
  end

  def deadline
    deadlines.where(current: true).ordered.take
  end

  def deadline_exceeded?
    deadline&.exceeded?
  end

  def booking_agent_responsible?
    booking_agent.present? && !committed_request
  end

  def cache_key
    [super, updated_at.to_i].join('-')
  end

  def to_liquid
    Manage::BookingSerializer.new(self).serializable_hash.deep_stringify_keys
  end

  private

  def assign_tenant_from_email
    return if email.blank?

    self.tenant ||= Tenant.find_or_initialize_by(email: email) do |tenant|
      tenant.country ||= 'CH'
    end
  end

  def set_occupancy_attributes
    self.occupancy    ||= build_occupancy
    occupancy.home    ||= home
    occupancy.booking ||= self
  end

  def set_ref
    self.ref ||= RefService.new.call(self)
  end
end
