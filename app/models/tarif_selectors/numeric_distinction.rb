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
  class NumericDistinction < TarifSelector
    def self.distinction_regex
      /\A([><=])?(\d*)\z/.freeze
    end

    validates :distinction, format: { with: distinction_regex }, allow_blank: true

    def apply?(usage, presumable_usage = presumable_usage(usage))
      distinction_match = self.class.distinction_regex.match(distinction) || return
      case distinction_match[1]
      when '<'
        presumable_usage < distinction_match[2].to_i
      when '>'
        presumable_usage > distinction_match[2].to_i
      else
        distinction_match[2].blank? || presumable_usage == distinction_match[2].to_i
      end
    end

    def presumable_usage(usage); end
  end
end
