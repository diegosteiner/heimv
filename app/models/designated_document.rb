# frozen_string_literal: true

# == Schema Information
#
# Table name: designated_documents
#
#  id               :bigint           not null, primary key
#  attached_to_type :string
#  designation      :integer          default(0)
#  locale           :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  attached_to_id   :bigint
#
# Indexes
#
#  index_designated_documents_on_attached_to  (attached_to_type,attached_to_id)
#
class DesignatedDocument < ApplicationRecord
  include LocaleEnumerable

  belongs_to :attached_to, polymorphic: true, optional: true

  enum designation: { undesignated: 0, privacy_statement: 1, terms: 2, house_rules: 3, pricelist: 4 }

  scope :localized, ->(locale = I18n.default) { where(locale: locale) }

  has_one_attached :file
end
