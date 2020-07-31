# == Schema Information
#
# Table name: usages
#
#  id                  :bigint           not null, primary key
#  presumed_used_units :decimal(, )
#  remarks             :text
#  used_units          :decimal(, )
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  booking_id          :uuid
#  tarif_id            :bigint
#
# Indexes
#
#  index_usages_on_booking_id               (booking_id)
#  index_usages_on_tarif_id_and_booking_id  (tarif_id,booking_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (booking_id => bookings.id)
#  fk_rails_...  (tarif_id => tarifs.id)
#

class Usage < ApplicationRecord
  after_initialize do
    self.class.include(tarif.class::UsageDecorator) if tarif && defined?(tarif.class::UsageDecorator)
  end

  belongs_to :tarif, -> { includes(:tarif_selectors) }, inverse_of: :usages
  belongs_to :booking, inverse_of: :usages
  has_many :invoice_parts, dependent: :nullify
  has_many :tarif_selectors, through: :tarif

  attribute :apply, default: true
  delegate(:position, to: :tarif)

  scope :ordered, -> { joins(:tarif).includes(:tarif).order(Tarif.arel_table[:position]) }
  scope :of_tarif, ->(tarif) { where(tarif_id: tarif.self_and_booking_copy_ids) }
  scope :amount, -> { joins(:tarif).where(tarifs: { type: Tarifs::Amount.to_s }) }

  before_create :create_tarif_booking_copy

  validates :tarif_id, uniqueness: { scope: :booking_id }, allow_nil: true
  # validates :used_units, numericality: true, presence: true

  def price
    ((used_units || 0).to_f * (tarif.price_per_unit || 1).to_f * 20.0).floor / 20.0
  end

  def presumed_price
    ((presumed_used_units || 0).to_f * (tarif.price_per_unit || 1).to_f * 20.0).floor / 20.0
  end

  def of_tarif?(other_tarif)
    other_tarif.self_and_booking_copy_ids.include?(tarif_id)
  end

  def create_tarif_booking_copy
    return if tarif.booking_copy? || tarif.transient?

    self.tarif = Tarifs::Factory.new.booking_copy_for(tarif, booking).tap(&:save)
  end

  def tarif_selector_votes
    @tarif_selector_votes ||= tarif_selectors.index_with do |selector|
      selector.vote_for(self)
    end
  end

  def adopted_by_vote?
    votes = tarif_selector_votes.values.flatten.compact
    votes.any? && votes.all?
  end

  def used?
    used_units.present? && used_units.positive?
  end
end
