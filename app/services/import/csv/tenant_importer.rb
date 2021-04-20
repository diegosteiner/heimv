# frozen_string_literal: true

module Import
  module Csv
    class TenantImporter < Base
      attr_reader :organisation

      def initialize(organisation, **options)
        super(options.reverse_merge)
        @organisation = organisation
      end

      def new_record
        Tenant.new(organisation: organisation)
      end

      actor do |tenant, row|
        tenant.phone = row.slice('phone', 'phone_1', 'phone_2').join("\n")
      end

      actor do |tenant, row|
        tenant.country_code = row['country_code'].presence
      end

      actor do |tenant, row|
        tenant.assign_attributes(first_name: row['first_name'].presence, last_name: row['last_name'].presence,
                                 street_address: row['street_address'].presence, zipcode: row['zipcode'].presence,
                                 city: row['city'].presence, email: row['email'].presence,
                                 remarks: row['remarks'].presence)
      end
    end
  end
end
