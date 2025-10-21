# frozen_string_literal: true

# == Schema Information
#
# Table name: tenants
#
#  id                        :bigint           not null, primary key
#  accounting_account_nr     :string
#  address_addon             :string
#  birth_date                :date
#  bookings_without_contract :boolean          default(FALSE)
#  bookings_without_invoice  :boolean          default(FALSE)
#  city                      :string
#  country_code              :string           default("CH")
#  email                     :string
#  email_verified            :boolean          default(FALSE)
#  first_name                :string
#  import_data               :jsonb
#  last_name                 :string
#  locale                    :string
#  nickname                  :string
#  phone                     :text
#  ref                       :string
#  remarks                   :text
#  reservations_allowed      :boolean          default(TRUE)
#  salutation_form           :integer
#  search_cache              :text             not null
#  sequence_number           :integer
#  street                    :string
#  street_nr                 :string
#  zipcode                   :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  organisation_id           :bigint           not null
#

class Tenant < ApplicationRecord
  has_many :bookings, dependent: :restrict_with_error, validate: false
  belongs_to :organisation

  locale_enum default: I18n.locale
  enum :salutation_form, { informal_neutral: 1, informal_female: 2, informal_male: 3, formal_neutral: 4,
                           formal_female: 5, formal_male: 6 }, prefix: :salutation_form, default: :informal_neutral

  normalizes :email, with: ->(email) { email.present? ? EmailAddress.normal(email) : nil }

  validates :email, allow_blank: true, uniqueness: { scope: :organisation_id }
  validates :email, presence: true, on: :public_update
  validates :first_name, :last_name, :street, :street_nr, :zipcode, :city, presence: true, on: :public_update
  validates :street, length: { maximum: 255 }
  validates :street_nr, length: { maximum: 25 }
  validates :phone, presence: true, length: { minimum: 10, maximum: 255 }, on: :public_update
  validates :locale, presence: true, on: :public_update
  validates :ref, uniqueness: { scope: :organisation_id }, allow_blank: true # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :birth_date, presence: true, on: :public_update, if: :birth_date_required?
  validate do
    errors.add(:email, :invalid) unless email.nil? || EmailAddress.valid?(email)
  end

  scope :ordered, -> { order(last_name: :ASC, first_name: :ASC, id: :ASC) }

  after_validation { errors.delete(:bookings) }
  before_save :sequence_number, :generate_ref
  before_save { self.search_cache = contact_lines.join('\n') }

  def full_name
    [[first_name, last_name].compact_blank.join(' '), nickname].compact_blank.join(' / ')
  end

  def name
    full_name
  end

  def names
    @names ||= {
      first_name: first_name.presence,
      last_name: last_name.presence,
      full_name:,
      nickname: nickname.presence,
      informal_name: [nickname, first_name].compact_blank.first
    }
  end

  def salutation
    salutations[salutation_form&.to_sym]
  end

  def salutations
    self.class.salutation_forms.keys.index_with do |salutation_form|
      self.class.human_enum(:salutation_forms, salutation_form, **names, default: nil)
    end.symbolize_keys
  end

  def sequence_number
    self[:sequence_number] ||= organisation.key_sequences.key(Tenant.sti_name).lease!
  end

  def generate_ref(force: false)
    self.ref = RefBuilders::Tenant.new(self).generate if ref.blank? || force
  end

  def address_lines
    raise NotImplementedError
  end

  def full_address_lines
    raise NotImplementedError
  end

  def contact_lines
    address.lines + [phone&.lines, email].flatten.compact_blank
  end

  def contact_info
    [phone&.lines, email].flatten.compact_blank.join(', ')
  end

  def to_s
    "##{id} #{full_name}"
  end

  def complete?
    valid? && address.complete? && (!birth_date_required? || birth_date.present?)
  end

  def changed_values
    changes.transform_values(&:last)
  end

  def birth_date_required?
    organisation&.settings&.tenant_birth_date_required
  end

  def merge_with_new(tenant)
    return self if tenant == self || tenant.persisted?

    assign_attributes(tenant&.changed_values&.except(:email, :organisation_id) || {})
    self
  end

  def address
    Address.clean(recipient: full_name, suffix: address_addon, street:, street_nr:, postalcode: zipcode,
                  city:, country_code:)
  end
end
