# frozen_string_literal: true

module Import
  module Csv
    class TenantImporter < Base
      attr_reader :organisation

      def initialize(organisation, **options)
        super(options)
        @organisation = organisation
      end

      def initialize_record(row)
        email = row.try_field('email')&.strip
        return Tenant.new(organisation: organisation) if email.blank?

        Tenant.find_or_initialize_by(email: email, organisation: organisation)
      end

      actor do |tenant, row|
        tenant.phone = row.try_all_fields('phone', 'phone_1', 'phone_2').join("\n")
      end

      actor do |tenant, row|
        tenant.import_data = row.to_h
      end

      actor do |tenant, row|
        tenant.country_code = row['country_code'].presence
      end

      actor do |tenant, row|
        tenant.assign_attributes(first_name: row.try_field('first_name', 'vorname'),
                                 last_name: row.try_field('last_name', 'nachname'),
                                 street_address: row.try_field('street_address', 'address', 'adresse', 'strasse'),
                                 zipcode: row.try_field('zipcode', 'zip', 'plz'),
                                 city: row.try_field('city', 'place', 'ort'),
                                 remarks: row['remarks'].presence)
      end
    end
  end
end
