# frozen_string_literal: true

module Import
  module Csv
    class TenantImporter < Base
      attr_reader :organisation

      def initialize(organisation, **options)
        super(**options)
        @organisation = organisation
      end

      def initialize_record(row)
        email = row['tenant.email']&.strip
        return Tenant.new(organisation: organisation) if email.blank?

        Tenant.find_or_initialize_by(email: email, organisation: organisation)
      end

      actor do |tenant, row|
        tenant.phone = [row['tenant.phone'], row['tenant.phone_2'], row['tenant.phone_3']].compact_blank.join("\n")
      end

      actor do |tenant, row|
        tenant.import_data = row.to_h
      end

      actor do |tenant, row|
        tenant.country_code = row['tenant.country_code'].presence
      end

      actor do |tenant, row|
        street_address = [row['tenant.street_address'], row['tenant.street_address_2']].compact_blank.join("\n")
        tenant.assign_attributes(first_name: row['tenant.first_name'], last_name: row['tenant.last_name'],
                                 nickname: row['tenant.nickname'],
                                 street_address: street_address,
                                 zipcode: row['tenant.zipcode'], city: row['tenant.city'],
                                 remarks: row['tenant.remarks'].presence)
      end

      actor do |tenant, row|
        names = row['tenant.name']&.split
        next if names.blank?

        tenant.assign_attributes(first_name: names[0..-2].join(' '), last_name: names.last)
      end
    end
  end
end
