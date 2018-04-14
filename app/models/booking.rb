class Booking < ApplicationRecord
  include BookingState

  attr_accessor :strict_validation

  has_one :occupancy, dependent: :destroy, as: :subject, inverse_of: :subject, autosave: true
  belongs_to :home
  belongs_to :customer, inverse_of: :bookings
  belongs_to :booking_agent, foreign_key: :booking_agent_code, primary_key: :code,
                             inverse_of: :bookings, required: false
  has_many :contracts, dependent: :destroy, autosave: false
  has_many :invoices, dependent: :destroy, autosave: false
  has_many :tarifs, dependent: :destroy, autosave: false

  validates :home, :customer, :occupancy, :email, presence: true
  validates :email, format: Devise.email_regexp
  validates :cancellation_reason, presence: true, allow_nil: true

  validates :committed_request, inclusion: { in: [true, false] }, if: :strict_validation
  validates :approximate_headcount, numericality: true, if: :strict_validation

  before_validation :set_occupancy_attributes
  before_validation :assign_customer_from_email
  after_create :reload

  accepts_nested_attributes_for :occupancy, reject_if: :all_blank, update_only: true
  accepts_nested_attributes_for :customer, reject_if: :all_blank, update_only: true

  def ref
    # TODO: Save this as an attribute
    @ref ||= RefService.new.booking(self)
  end

  def to_s
    ref
  end

  def bills; end

  def email
    customer&.email || self[:email]
  end

  private

  def assign_customer_from_email
    return if email.blank?
    self.customer ||= Customer.find_or_initialize_by(email: email).tap do |customer|
      # customer.strict_validation ||= strict_validation
      customer.skip_exact_validation ||= strict_validation.nil?
    end
  end

  def set_occupancy_attributes
    self.occupancy ||= build_occupancy
    occupancy.home ||= home
    occupancy.subject ||= self
  end
end
