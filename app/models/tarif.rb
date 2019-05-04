# == Schema Information
#
# Table name: tarifs
#
#  id                       :bigint(8)        not null, primary key
#  type                     :string
#  label                    :string
#  transient                :boolean          default(FALSE)
#  booking_id               :uuid
#  home_id                  :bigint(8)
#  booking_copy_template_id :bigint(8)
#  unit                     :string
#  price_per_unit           :decimal(, )
#  valid_from               :datetime
#  valid_until              :datetime
#  position                 :integer
#  tarif_group              :string
#  invoice_type             :string
#  prefill_usage_method     :string
#  meter                    :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class Tarif < ApplicationRecord
  extend TemplateRenderable
  include TemplateRenderable

  belongs_to :booking, autosave: false, optional: true
  belongs_to :home, optional: true
  belongs_to :booking_copy_template, class_name: 'Tarif', optional: true, inverse_of: :booking_copies
  has_many :booking_copies, class_name: 'Tarif', dependent: :nullify, inverse_of: :booking_copy_template,
                            foreign_key: :booking_copy_template_id
  has_many :usages, dependent: :restrict_with_error, inverse_of: :tarif
  has_many :tarif_tarif_selectors, dependent: :destroy, inverse_of: :tarif
  has_many :tarif_selectors, through: :tarif_tarif_selectors
  has_many :meter_reading_periods, dependent: :destroy, inverse_of: :tarif

  acts_as_list scope: [:home_id]
  scope :ordered, -> { order(:position) }
  scope :transient, -> { where(transient: true) }
  scope :valid_now, -> { where(valid_until: nil) }
  # scope :valid_at, ->(at = Time.zone.now) { where(valid_until: nil) }
  scope :applicable_to, ->(booking) { booking.home.tarifs.transient.or(where(booking: booking)).order(position: :asc) }

  enum prefill_usage_method: Hash[TarifPrefiller::PREFILL_METHODS.keys.map { |method| [method, method] }]

  validates :type, presence: true

  def unit_prefix
    self.class.human_attribute_name(:unit_prefix, default: '')
  end

  def unit_with_prefix
    [unit_prefix, unit].reject(&:blank?).join(' ')
  end

  def parent
    booking || home
  end

  def booking_copy?
    booking_id.present?
  end

  def original
    booking_copy_template || self
  end

  def self_and_booking_copy_ids
    [id] + booking_copy_ids
  end

  def <=>(other)
    position <=> other.position
  end
end
