class Booking < ApplicationRecord
  include BookingState

  attr_accessor :skip_exact_validation

  has_one :occupancy, dependent: :destroy, as: :subject, autosave: true
  belongs_to :home
  belongs_to :customer, inverse_of: :bookings
  has_many :contracts, dependent: :destroy, autosave: false

  validates :home, :customer, :occupancy, :email, presence: true
  validates :cancellation_reason, presence: true, allow_nil: true

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

  def skip_exact_validation?
    skip_exact_validation || cancellation_reason.present?
  end

  private

  def assign_customer_from_email
    return if email.blank?
    self.customer ||= Customer.find_or_initialize_by(email: email).tap do |customer|
      customer.skip_exact_validation ||= skip_exact_validation?
    end
  end

  def set_occupancy_attributes
    self.occupancy ||= build_occupancy
    occupancy.home ||= home
    occupancy.subject ||= self
  end
end
