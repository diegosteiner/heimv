class Booking < ApplicationRecord
  include BookingState

  has_one :occupancy, dependent: :destroy, as: :subject, autosave: true
  belongs_to :home
  belongs_to :customer, inverse_of: :bookings
  has_many :contracts, dependent: :destroy, autosave: false

  validates :home, :customer, :occupancy, presence: true

  before_validation :set_occupancy_attributes
  before_create :generate_public_id

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

  private

  def generate_public_id
    # self.public_id ||= SecureRandom.urlsafe_base64(32)
  end

  def set_occupancy_attributes
    self.occupancy ||= build_occupancy
    occupancy.home ||= home
    occupancy.subject ||= self
  end
end
