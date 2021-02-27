# frozen_string_literal: true

module Import
  class BookingPurposeImporter < Base
    def relevant_attributes
      %w[key title_i18n]
    end

    protected

    def to_h
      organisation.booking_purposes.find_each.map do |purpose|
        [purpose.key, purpose.attributes.slice(*relevant_attributes)]
      end.to_h
    end

    def from_h(serialized)
      serialized.map do |_key, attributes|
        purpose = organisation.booking_purposes.find_or_initialize_by(key: ley)
        purpose.update(attributes.slice(*relevant_attributes)) if purpose.new_record? || options[:replace]
        purpose if purpose.valid?
      end
    end
  end
end
