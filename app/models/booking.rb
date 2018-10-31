class Booking < ApplicationRecord
  include BookingState
  include Statesman::Adapters::ActiveRecordQueries

  attr_accessor :strict_validation, :initiator # TODO: Replace with validation context

  has_one :occupancy, dependent: :destroy, inverse_of: :booking, autosave: true
  belongs_to :home
  belongs_to :tenant, inverse_of: :bookings
  belongs_to :booking_agent, foreign_key: :booking_agent_code, primary_key: :code,
                             inverse_of: :bookings, required: false
  has_many :contracts, -> { order(valid_from: :ASC) }, dependent: :destroy, autosave: false, inverse_of: :booking
  has_many :invoices, dependent: :destroy, autosave: false
  has_many :payments, dependent: :destroy, autosave: false
  has_many :usages, dependent: :destroy # , autosave: false
  has_many :used_tarifs, class_name: :Tarif, through: :usages, source: :tarif, inverse_of: :booking
  has_many :applicable_tarifs, ->(booking) { Tarif.applicable_to(booking) }, class_name: :Tarif, inverse_of: :booking
  has_many :booking_copy_tarifs, class_name: :Tarif, dependent: :destroy
  has_many :transitive_tarifs, class_name: :Tarif, through: :home, source: :tarif
  has_many :deadlines, dependent: :destroy, inverse_of: :booking
  has_many :messages, dependent: :destroy, inverse_of: :booking

  validates :home, :tenant, :occupancy, :email, presence: true
  validates :email, format: Devise.email_regexp
  validates :cancellation_reason, presence: true, allow_nil: true
  validates :committed_request, inclusion: { in: [true, false] }, if: :strict_validation
  validates :approximate_headcount, numericality: true, if: :strict_validation

  validate(on: :public_update) do
  end

  validate(on: :public_create) do
    errors.add(:base, :conflicting) if occupancy.conflicting.any?
  end

  before_validation :set_occupancy_attributes
  before_validation :assign_tenant_from_email
  after_create :reload

  accepts_nested_attributes_for :occupancy, reject_if: :all_blank, update_only: true
  accepts_nested_attributes_for :tenant, reject_if: :all_blank, update_only: true
  accepts_nested_attributes_for :usages, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :deadlines, reject_if: :all_blank, update_only: true

  def ref
    @ref ||= RefService.new.call(self)
  end

  def to_s
    ref
  end

  def email
    tenant&.email || self[:email]
  end

  def overnight_stays
    occupancy.nights * approximate_headcount
  end

  def self.transition_class
    BookingTransition
  end

  def deadline_exceeded?
    deadlines.current&.exceeded?
  end

  private

  def assign_tenant_from_email
    return if email.blank?

    self.tenant ||= Tenant.find_or_initialize_by(email: email).tap do |tenant|
      # tenant.strict_validation ||= strict_validation
      tenant.skip_exact_validation ||= strict_validation.nil?
    end
  end

  def set_occupancy_attributes
    self.occupancy ||= build_occupancy
    occupancy.home ||= home
    occupancy.booking ||= self
  end
end
