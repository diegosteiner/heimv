# frozen_string_literal: true

# == Schema Information
#
# Table name: designated_documents
#
#  id                   :bigint           not null, primary key
#  attaching_conditions :jsonb
#  designation          :integer
#  locale               :string
#  name                 :string
#  remarks              :text
#  send_with_accepted   :boolean          default(FALSE), not null
#  send_with_contract   :boolean          default(FALSE), not null
#  send_with_last_infos :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  organisation_id      :bigint           not null
#
class DesignatedDocument < ApplicationRecord
  include StoreModel::NestedAttributes

  belongs_to :organisation, inverse_of: :designated_documents

  has_many :mail_template_designated_documents, dependent: :delete_all
  has_many :mail_templates, through: :mail_template_designated_documents

  locale_enum
  enum :designation, { other: 0, privacy_statement: 1, terms: 2, house_rules: 3, price_list: 4 }

  attribute :attaching_conditions, BookingCondition.one_of.to_array_type, nil: true

  scope :with_locale, ->(locale) { where(locale: [locale, nil]).order(locale: :ASC) }
  scope :for_booking, (lambda do |booking|
    candidates = where(organisation: booking.organisation).with_locale(booking.locale)
    where(id: candidates.filter_map { |document| document.attach_to?(booking) && document.id })
  end)

  has_one_attached :file

  delegate :blob, :content_type, :filename, to: :file, allow_nil: true

  validates :file, presence: true
  validates :attaching_conditions, store_model: true, allow_nil: true

  accepts_nested_attributes_for :attaching_conditions, allow_destroy: true

  def locale=(value)
    super(value.presence)
  end

  def to_attachable
    { io: StringIO.new(blob.download), filename:, content_type: } if blob.present?
  end

  def attach_to?(booking)
    attaching_conditions.blank? || attaching_conditions.all? { it.fullfills?(booking) }
  end

  def initialize_copy(origin)
    super
    self.attaching_conditions = origin.attaching_conditions.dup
    return if origin.file.blank?

    file.attach(io: StringIO.new(origin.file.download),
                filename: origin.file.filename,
                content_type: origin.file.content_type)
  end
end
