# frozen_string_literal: true

# == Schema Information
#
# Table name: key_sequences
#
#  id              :bigint           not null, primary key
#  key             :string           not null
#  value           :integer          default(0), not null
#  year            :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organisation_id :bigint           not null
#
class KeySequence < ApplicationRecord
  belongs_to :organisation, inverse_of: :key_sequences

  validates :key, presence: true, uniqueness: { scope: %i[organisation_id year] }

  scope :key, ->(key, year: nil) { find_or_create_by(key:, year: (year == :current ? Time.zone.today.year : year)) }

  def lease!
    increment!(:value).value # rubocop:disable Rails/SkipsModelValidations
  end

  def self.backfill_invoices(organisation, generate_ref: false)
    organisation.invoices.order(created_at: :ASC).each do |invoice|
      invoice.skip_generate_pdf = true
      invoice.sequence_number
      invoice.generate_ref if generate_ref
      invoice.save
    end
  end

  def self.backfill_tenants(organisation, generate_ref: false)
    organisation.tenants.order(created_at: :ASC).each do |tenant|
      tenant.sequence_number
      tenant.generate_ref if generate_ref
      tenant.save
    end
  end

  def self.backfill_bookings(organisation, generate_ref: false)
    organisation.bookings.order(begins_at: :ASC).each do |tenant|
      tenant.sequence_number
      tenant.generate_ref if generate_ref
      tenant.save
    end
  end
end
