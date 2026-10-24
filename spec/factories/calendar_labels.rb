# frozen_string_literal: true

# == Schema Information
#
# Table name: calendar_labels
#
#  id                          :bigint           not null, primary key
#  color                       :string           not null
#  conflict_type_default       :integer
#  description_i18n            :jsonb            not null
#  discarded_at                :datetime
#  legend                      :boolean          default(TRUE), not null
#  title_i18n                  :jsonb            not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  booking_categories_id       :bigint
#  booking_category_default_id :bigint
#  organisation_id             :bigint
#
FactoryBot.define do
  factory :calendar_label do
    organisation
    title_i18n { { en: 'Pending', de: 'Ausstehend' } }
    description_i18n { { en: 'Pending occupancy', de: 'Ausstehende Belegung' } }
    color { '#3498db' }
    legend { true }
  end
end
