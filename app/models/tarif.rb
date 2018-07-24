class Tarif < ApplicationRecord
  include RankedModel
  belongs_to :booking, autosave: false, optional: true
  belongs_to :home, optional: true
  belongs_to :booking_copy_template, class_name: :Tarif, optional: true, inverse_of: :booking_copies
  has_many :booking_copies, class_name: :Tarif, dependent: :nullify, inverse_of: :booking_copy_template,
                                foreign_key: :booking_copy_template_id
  has_many :usages, dependent: :restrict_with_error, inverse_of: :tarif
  has_one :usage_calculator, -> { UsageCalculator.where(tarif: [self, template].compact) }, inverse_of: :tarif

  ranks :row_order, with_same: :home_id
  scope :transient, -> { where(transient: true) }
  scope :applicable_to, ->(booking) { booking.home.tarifs.transient.or(where(booking: booking)).rank(:row_order) }

  validates :type, presence: true

  def parent
    booking || home
  end

  def booking_copy?
    booking_id.present?
  end

  def override_used_units?
    false
  end

  def override_used_units(usage)
    usage[:used_units]
  end
end
