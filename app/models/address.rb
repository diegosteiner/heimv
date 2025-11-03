# frozen_string_literal: true

class Address
  include StoreModel::Model
  extend ActiveModel::Naming
  extend ActiveModel::Translation
  extend TemplateRenderable

  attribute :recipient
  attribute :suffix
  attribute :representing
  attribute :street
  attribute :street_nr
  attribute :postalcode
  attribute :city
  attribute :country_code, default: -> { 'CH' }

  validates :country_code, inclusion: { in: ISO3166::Country.codes }

  def organisation
    return parent if parent.is_a?(Organisation)

    parent.try(:organisation)
  end

  def street_line
    [street, street_nr].compact_blank.join(' ')
  end

  def postal_line
    [postalcode, city, country_code == organisation&.country_code ? nil : country_code].compact_blank.join(' ')
  end

  def lines
    [
      recipient,
      suffix.presence,
      street_line,
      postal_line
    ].compact
  end

  def to_s
    lines.join("\n")
  end

  def complete?
    attributes.slice(*%w[recipient street street_nr postalcode city country_code]).values.all?(&:present?)
  end

  def blank?
    attributes.slice(*%w[recipient street street_nr postalcode city]).values.all?(&:blank?)
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
    suffix = lines.pop if lines.many?
    recipient = lines.join(', ')
    Address.clean(recipient:, suffix:, street:, street_nr:, postalcode:, city:, **defaults)
  end
end
