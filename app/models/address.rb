# frozen_string_literal: true

class Address
  include StoreModel::Model
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  delegate :organisation, to: :parent, allow_nil: true

  attribute :recipient
  attribute :suffix
  attribute :representing
  attribute :street
  attribute :street_nr
  attribute :postalcode
  attribute :city
  attribute :country_code

  validates :country_code, inclusion: { in: ISO3166::Country.codes }

  def street_line
    [street, street_nr].compact_blank.join(' ')
  end

  def postal_line
    [postalcode, city, country_code == organisation&.country_code ? nil : country_code].compact_blank.join(' ')
  end

  def lines
    [
      recipient,
      suffix,
      street_line,
      postal_line
    ]
  end

  def to_s
    lines.join("\n")
  end

  def complete?
    attributes.slice(:recipient, :street, :street_nr, :postalcode, :city, :country_code).all?(&:present?)
  end

  def self.clean(**attributes)
    new(**attributes.transform_values { it&.strip })
  end

  def self.parse_lines(lines, **defaults)
    lines = lines.lines if lines.is_a?(String)
    lines = lines.compact_blank if lines.is_a?(Array)
    return if lines.blank?

    postalcode, _, city = lines.pop&.partition(' ')
    street, _, street_nr = lines.pop&.rpartition(' ')
    recipient = lines.join(', ')
    Address.clean(recipient:, street:, street_nr:, postalcode:, city:, **defaults)
  end
end
