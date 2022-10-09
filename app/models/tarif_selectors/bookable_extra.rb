# frozen_string_literal: true

# == Schema Information
#
# Table name: tarif_selectors
#
#  id          :bigint           not null, primary key
#  distinction :string
#  type        :string
#  veto        :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  tarif_id    :bigint
#
# Indexes
#
#  index_tarif_selectors_on_tarif_id  (tarif_id)
#
# Foreign Keys
#
#  fk_rails_...  (tarif_id => tarifs.id)
#

module TarifSelectors
  class BookableExtra < TarifSelector
    TarifSelector.register_subtype self

    validate do
      next if organisation.bookable_extras.exists?(id: distinction)

      errors.add(:distinction, :invalid)
    end

    def apply?(usage)
      usage.booking.bookable_extra_ids.include?(distinction&.to_i)
    end
  end
end
