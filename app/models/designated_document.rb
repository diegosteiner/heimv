# frozen_string_literal: true

# == Schema Information
#
# Table name: designated_documents
#
#  id              :bigint           not null, primary key
#  designation     :integer
#  locale          :string
#  remarks         :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  home_id         :bigint
#  organisation_id :bigint           not null
#
# Indexes
#
#  index_designated_documents_on_home_id                  (home_id)
#  index_designated_documents_on_organisation_id          (organisation_id)
#  index_designated_documentss_on_designation_and_locale  (designation,locale,home_id,organisation_id) UNIQUE
#
class DesignatedDocument < ApplicationRecord
  belongs_to :organisation, inverse_of: :designated_documents
  belongs_to :home, optional: true, inverse_of: :designated_documents

  enum designation: { undesignated: 0, privacy_statement: 1, terms: 2, house_rules: 3, price_list: 4 }

  has_one_attached :file

  validates :file, presence: true
  validates :designation, uniqueness: { scope: %i[locale organisation_id home_id], allow_blank: true }

  def locale=(value)
    super(value.presence)
  end

  def self.localized!(designation, locale: I18n.locale)
    where(designation: designation, locale: [locale, nil]).order(locale: :ASC).take!
  end

  def self.localized(...)
    localized!(...)
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
