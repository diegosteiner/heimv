# frozen_string_literal: true

class KeySequence < ApplicationRecord
  belongs_to :organisation, inverse_of: :key_sequences

  validates :key, presence: true, uniqueness: { scope: %i[organisation_id year] }

  scope :key, ->(key, year: nil) { find_or_create_by(key:, year: (year == :current ? Time.zone.today.year : year)) }

  def lease!
    increment!(:value).value # rubocop:disable Rails/SkipsModelValidations
  end

  def self.backfill_invoices(organisation)
    organisation.invoices.order(created_at: :ASC).each do |invoice|
      invoice.sequence_number
      invoice.skip_generate_pdf = true
      invoice.save
    end
  end

  def self.backfill_tenants(organisation)
    organisation.tenants.order(created_at: :ASC).each do |tenant|
      tenant.sequence_number
      tenant.save
    end
  end

  def self.backfill_bookings(organisation)
    organisation.bookings.order(created_at: :ASC).each do |tenant|
      tenant.sequence_number
      tenant.save
    end
  end
end
