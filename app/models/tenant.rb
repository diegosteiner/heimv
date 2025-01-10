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
#  remarks                   :text
#  reservations_allowed      :boolean          default(TRUE)
#  salutation_form           :integer
#  search_cache              :text             not null
#  street_address            :string
#  zipcode                   :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  organisation_id           :bigint           not null
#
# Indexes
#
#  index_tenants_on_email                      (email)
#  index_tenants_on_email_and_organisation_id  (email,organisation_id) UNIQUE
#  index_tenants_on_organisation_id            (organisation_id)
#  index_tenants_on_search_cache               (search_cache)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
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
  validates :first_name, :last_name, :street_address, :zipcode, :city, presence: true, on: :public_update
  validates :street_address, length: { maximum: 255 }
  validates :phone, presence: true, length: { minimum: 10, maximum: 255 }, on: :public_update
  validates :locale, presence: true, on: :public_update
  validates :birth_date, presence: true, on: :public_update, if: :birth_date_required?
  validate do
    errors.add(:email, :invalid) unless email.nil? || EmailAddress.valid?(email)
  end

  scope :ordered, -> { order(last_name: :ASC, first_name: :ASC, id: :ASC) }

  after_validation { errors.delete(:bookings) }
  before_create :sequence_number, :generate_ref
  before_save { self.search_cache = contact_lines.flatten.join('\n') }

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
    [
      address_addon&.strip,
      street_address&.lines&.map(&:strip),
      [zipcode, city, country_code != organisation&.country_code && country_code].compact_blank.join(' ')
    ].flatten.compact_blank
  end

  def full_address_lines
    [full_name, address_lines].flatten
  end

  def address
    full_address_lines.join("\n")
  end

  def contact_lines
    full_address_lines + [phone&.lines, email].flatten.compact_blank
  end

  def contact_info
    [phone&.lines, email].flatten.compact_blank.join(', ')
  end

  def to_s
    "##{id} #{names[:full_name]}"
  end

  def complete?
    valid? &&
      [email, first_name, last_name, street_address, zipcode, city, country_code, phone].all?(&:present?) &&
      (!birth_date_required? || birth_date.present?)
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
end
