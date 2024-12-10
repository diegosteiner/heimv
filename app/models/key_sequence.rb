# frozen_string_literal: true

class KeySequence < ApplicationRecord
  belongs_to :organisation, inverse_of: :key_sequences

  validates :key, presence: true, uniqueness: { scope: %i[organisation_id year] }

  scope :key, ->(key, year: nil) { find_or_create_by(key:, year: (year == :current ? Time.zone.today.year : year)) }

  def lease!
    increment!(:value).value # rubocop:disable Rails/SkipsModelValidations
  end

  # module ActiveRecord
  #   extend ActiveSupport::Concern

  #   class_methods do
  #     def sequence_number(key, column = :sequence_number, year: nil)
  #       before_save do
  #         # year = year.call if year.respond_to?(:call)
  #         leased_sequence_number = organisation&.key_sequences&.key(key, year: year)&.lease!
  #         try("#{column}||=", leased_sequence_number) if leased_sequence_number.present?
  #       end
  #     end
  #   end
  # end
end
