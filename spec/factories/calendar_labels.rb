# frozen_string_literal: true

# == Schema Information
#
# Table name: calendar_labels
#
#  id                       :bigint           not null, primary key
#  color                    :string           not null
#  description_i18n         :jsonb            not null
#  discarded_at             :datetime
#  occupancy_status_default :integer
#  title_i18n               :jsonb            not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  organisation_id          :bigint
#
FactoryBot.define do
  factory :calendar_label do
    organisation
    title_i18n { { en: 'Pending', de: 'Ausstehend' } }
    description_i18n { { en: 'Pending occupancy', de: 'Ausstehende Belegung' } }
    color { '#3498db' }
    occupancy_status_default { 'pending' }
  end
end
