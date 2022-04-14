# frozen_string_literal: true

# == Schema Information
#
# Table name: designated_documents
#
#  id                 :bigint           not null, primary key
#  designation        :integer
#  locale             :string
#  name               :string
#  remarks            :text
#  send_with_contract :boolean          default(FALSE), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  home_id            :bigint
#  organisation_id    :bigint           not null
#
# Indexes
#
#  index_designated_documents_on_home_id          (home_id)
#  index_designated_documents_on_organisation_id  (organisation_id)
#
class DesignatedDocument < ApplicationRecord
  belongs_to :organisation, inverse_of: :designated_documents
  belongs_to :home, optional: true, inverse_of: :designated_documents

  locale_enum
  enum designation: { other: 0, privacy_statement: 1, terms: 2, house_rules: 3, price_list: 4 }

  scope :with_locale, ->(locale) { where(locale: [locale, nil]).order(locale: :ASC) }
  scope :blobs, -> { filter_map { |designated_document| designated_document.file&.blob } }
  scope :in_context, (lambda do |context|
    next where(organisation: context, home: nil) if context.is_a?(Organisation)
    next where(organisation: context.organisation, home: [context, nil]).order(home_id: :ASC) if context.is_a?(Home)
    next in_context(context.home) if context.respond_to?(:home)
    next in_context(context.organisation) if context.respond_to?(:organisation)
  end)

  has_one_attached :file

  delegate :blob, to: :file, allow_nil: true

  validates :file, presence: true
  # validates :designation, uniqueness: { scope: %i[locale organisation_id home_id], allow_blank: true }

  def locale=(value)
    super(value.presence)
  end
end
