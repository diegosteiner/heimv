# frozen_string_literal: true

module Import
  module Csv
    class TenantImporter < Base
      attr_reader :organisation

      def self.supported_headers
        super + ['tenant.email', 'tenant.phone*', 'tenant.remarks', 'tenant.country_code', 'tenant.zipcode',
                 'tenant.city', 'tenant.street', 'tenant.name', 'tenant.first_name', 'tenant.last_name',
                 'tenant.nickname', 'tenant.address_addon', 'tenant.locale']
      end

      def initialize(organisation, **)
        super(**)
        @organisation = organisation
      end

      def initialize_record(row)
        email = row['tenant.email']&.strip
        return Tenant.new(organisation:) if email.blank?

        Tenant.find_or_initialize_by(email:, organisation:)
      end

      actor do |tenant, row|
        tenant.phone = row.filter_map do |header, value|
          header&.starts_with?('tenant.phone') && value
        end.compact_blank.join("\n")
      end

      actor do |tenant, row|
        tenant.import_data = row.to_h
        tenant.remarks = row['tenant.remarks'].presence
      end

      actor do |tenant, row|
        tenant.country_code = row['tenant.country_code'].presence
        tenant.assign_attributes(zipcode: row['tenant.zipcode'], city: row['tenant.city'],
                                 address_addon: row['tenant.address_addon'])
        tenant.street_address = row.filter_map do |header, value|
          header&.starts_with?('tenant.street') && value
        end.compact_blank.join("\n")
      end

      actor do |tenant, row|
        tenant.locale ||= row['tenant.locale'] || organisation.locale
      end

      actor do |tenant, row|
        names = row['tenant.name']&.split
        tenant.first_name = row['tenant.first_name'] || (names && names[0..-2].join(' '))
        tenant.last_name = row['tenant.last_name'] || (names && names.last)
        tenant.nickname = row['tenant.nickname'].presence
      end
    end
  end
end
