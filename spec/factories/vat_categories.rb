# frozen_string_literal: true

# == Schema Information
#
# Table name: vat_categories
#
#  id                  :bigint           not null, primary key
#  accounting_vat_code :string
#  discarded_at        :datetime
#  label_i18n          :jsonb            not null
#  percentage          :decimal(, )      default(0.0), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  organisation_id     :bigint           not null
#
# Indexes
#
#  index_vat_categories_on_discarded_at     (discarded_at)
#  index_vat_categories_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#
FactoryBot.define do
  factory :vat_category do
    percentage { 8.1 }
    label { 'Normalsatz' }
    organisation
    accounting_vat_code { '' }
  end
end
