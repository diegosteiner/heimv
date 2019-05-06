class Organisation < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error, inverse_of: :organisation
  has_many :homes, dependent: :restrict_with_error, inverse_of: :organisation
  has_one_attached :logo

  validates :booking_strategy_type, presence: true
  validates :invoice_ref_strategy_type, presence: true
  validates :name, :address, :payment_information, :account_nr, presence: true

  def self.instance
    @instance ||= take!
  end

  def booking_strategy
    Kernel.const_get(booking_strategy_type).new
  end

  def invoice_ref_strategy
    Kernel.const_get(invoice_ref_strategy_type).new
  end

  def to_s
    name
  end
end
