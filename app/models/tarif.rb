# frozen_string_literal: true

# == Schema Information
#
# Table name: tarifs
#
#  id                       :bigint           not null, primary key
#  invoice_type             :string
#  label_i18n               :jsonb
#  meter                    :string
#  position                 :integer
#  prefill_usage_method     :string
#  price_per_unit           :decimal(, )
#  tarif_group              :string
#  tenant_visible           :boolean          default(TRUE)
#  transient                :boolean          default(FALSE)
#  type                     :string
#  unit_i18n                :jsonb
#  valid_from               :datetime
#  valid_until              :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  booking_copy_template_id :bigint
#  booking_id               :uuid
#  home_id                  :bigint
#
# Indexes
#
#  index_tarifs_on_booking_copy_template_id  (booking_copy_template_id)
#  index_tarifs_on_booking_id                (booking_id)
#  index_tarifs_on_home_id                   (home_id)
#  index_tarifs_on_type                      (type)
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
  has_many :tarif_selectors, dependent: :destroy, inverse_of: :tarif
  has_many :meter_reading_periods, dependent: :destroy, inverse_of: :tarif

  acts_as_list scope: [:home_id]
  scope :ordered, -> { order(:position) }
  scope :transient, -> { where(transient: true) }
  scope :valid_now, -> { where(valid_until: nil) }
  # scope :valid_at, ->(at = Time.zone.now) { where(valid_until: nil) }
  scope :applicable_to, ->(booking) { booking.home.tarifs.transient.or(where(booking: booking)).order(position: :asc) }
  scope :find_with_booking_copies, ->(tarif_ids) { where(id: tarif_ids).or(where(booking_copy_template_id: tarif_ids)) }

  enum prefill_usage_method: TarifPrefiller::PREFILL_METHODS.keys.index_with(&:to_s)

  validates :type, presence: true
  attribute :price_per_unit, default: 0

  extend Mobility
  translates :label, column_suffix: '_i18n', locale_accessors: true
  translates :unit, column_suffix: '_i18n', locale_accessors: true

  accepts_nested_attributes_for :tarif_selectors, reject_if: :all_blank, allow_destroy: true

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

  def organisation
    booking&.organisation || home&.organisation
  end

  def self_and_booking_copy_ids
    [id] + booking_copy_ids
  end

  def <=>(other)
    position <=> other.position
  end
end
