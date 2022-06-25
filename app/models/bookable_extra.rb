# frozen_string_literal: true

# == Schema Information
#
# Table name: bookable_extras
#
#  id               :bigint           not null, primary key
#  description_i18n :jsonb
#  key              :string
#  title_i18n       :jsonb
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  home_id          :bigint           not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_bookable_extras_on_home_id          (home_id)
#  index_bookable_extras_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (home_id => homes.id)
#  fk_rails_...  (organisation_id => organisations.id)
#
class BookableExtra < ApplicationRecord
  extend Mobility

  belongs_to :organisation, inverse_of: :bookable_extras
  belongs_to :home, optional: true, inverse_of: :bookable_extras
  has_many :booked_extras, dependent: :destroy
  has_many :bookings, through: :booked_extras

  translates :title, column_suffix: '_i18n', locale_accessors: true
  translates :description, column_suffix: '_i18n', locale_accessors: true
end
