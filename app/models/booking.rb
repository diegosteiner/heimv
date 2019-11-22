# == Schema Information
#
# Table name: bookings
#
#  id                    :uuid             not null, primary key
#  home_id               :bigint           not null
#  organisation_id       :bigint           not null
#  state                 :string           default("initial"), not null
#  tenant_organisation   :string
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
#  usages_entered        :boolean          default(FALSE)
#  messages_enabled      :boolean          default(FALSE)
#  import_data           :jsonb
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  booking_agent_code    :string
#  booking_agent_ref     :string
#

class Booking < ApplicationRecord
  include BookingState

  DEFAULT_INCLUDES = %i[organisation occupancy tenant home booking_transitions
                        invoices contracts deadlines payments].freeze

  belongs_to :organisation, inverse_of: :bookings
  belongs_to :home, inverse_of: :bookings
  belongs_to :tenant, inverse_of: :bookings, optional: true

  has_one :occupancy, dependent: :destroy, inverse_of: :booking, autosave: true
  has_one :agent_booking, dependent: :destroy, inverse_of: :booking

  has_many :invoices, dependent: :destroy, autosave: false
  has_many :payments, dependent: :destroy, autosave: false
  has_many :booking_copy_tarifs, dependent: :destroy, class_name: 'Tarif'
  has_many :deadlines, dependent: :destroy, inverse_of: :booking
  has_many :messages, dependent: :destroy, inverse_of: :booking

  has_many :applicable_tarifs, ->(booking) { Tarif.applicable_to(booking) }, class_name: 'Tarif', inverse_of: :booking
  has_many :usages, -> { ordered }, dependent: :destroy, inverse_of: :booking
  has_many :contracts, -> { ordered }, dependent: :destroy, autosave: false, inverse_of: :booking
  has_many :used_tarifs, through: :usages, class_name: 'Tarif', source: :tarif, inverse_of: :booking
  has_many :transitive_tarifs, through: :home, class_name: 'Tarif', source: :tarif
  has_one :booking_agent, through: :agent_booking

  validates :home, :occupancy, presence: true
  validates :email, format: Devise.email_regexp, presence: true, if: :committed_request?

  validates :accept_conditions, acceptance: true, on: :public_create
  validates :tenant, presence: true, on: :public_update
  validates :committed_request, inclusion: { in: [true, false] }, on: :public_update
  validates :purpose, presence: true, on: :public_update
  validates :approximate_headcount, numericality: true, on: :public_update

  validate(on: %i[public_create public_update]) do
    errors.add(:base, :conflicting) if occupancy.conflicting.any?
  end

  default_scope -> { ordered }
  scope :ordered, -> { order(created_at: :asc) }
  scope :with_default_includes, -> { includes(DEFAULT_INCLUDES) }

  before_validation :set_organisation
  before_validation :set_occupancy_attributes
  before_validation :assign_tenant_from_email
  before_create :set_ref
  after_create :reload

  accepts_nested_attributes_for :occupancy, reject_if: :all_blank, update_only: true
  accepts_nested_attributes_for :tenant, reject_if: :all_blank, update_only: true
  accepts_nested_attributes_for :usages, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :deadlines, reject_if: :all_blank, update_only: true
  accepts_nested_attributes_for :agent_booking, reject_if: :all_blank

  attribute :accept_conditions, default: false
  # enum purpose: { camp: :camp, event: :event }

  self.implicit_order_column = :created_at

  def to_s
    ref
  end

  def overnight_stays
    occupancy.nights * approximate_headcount
  end

  def editable!(value = true)
    # rubocop:disable Rails/SkipsModelValidations
    update_columns(editable: value)
    # rubocop:enable Rails/SkipsModelValidations
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

  def agent_booking?
    agent_booking.present?
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
    self.occupancy ||= build_occupancy
    occupancy.home ||= home
    occupancy.booking ||= self
  end

  def set_ref
    self.ref ||= RefStrategies::DefaultBookingRef.new.generate(self)
  end

  def set_organisation
    self.organisation ||= home&.organisation
  end
end
