# frozen_string_literal: true

# == Schema Information
#
# Table name: data_digest_templates
#
#  id               :bigint           not null, primary key
#  columns_config   :jsonb
#  group            :string
#  label            :string
#  prefilter_params :jsonb
#  type             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  organisation_id  :bigint           not null
#
# Indexes
#
#  index_data_digest_templates_on_organisation_id  (organisation_id)
#
# Foreign Keys
#
#  fk_rails_...  (organisation_id => organisations.id)
#

module DataDigestTemplates
  class Tenant < ::DataDigestTemplate
    ::DataDigestTemplate.register_subtype self
    DEFAULT_COLUMN_CONFIG = [
      {
        header: ::Tenant.model_name.human,
        body: '{{ tenant.full_name }}'
      },
      {
        header: ::Tenant.human_attribute_name(:address),
        body: "{{ tenant.address_addon }}\n{{ tenant.street_address }}"
      },
      {
        header: ::Tenant.human_attribute_name(:zipcode),
        body: '{{ tenant.zipcode }}'
      },
      {
        header: ::Tenant.human_attribute_name(:country_code),
        body: '{{ tenant.country_code }}'
      },
      {
        header: ::Tenant.human_attribute_name(:locale),
        body: '{{ tenant.locale }}'
      },
      {
        header: ::Tenant.human_attribute_name(:city),
        body: '{{ tenant.city }}'
      },
      {
        header: ::Tenant.human_attribute_name(:email),
        body: '{{ tenant.email }}'
      },
      {
        header: ::Tenant.human_attribute_name(:phone),
        body: '{{ tenant.phone }}'
      },
      {
        header: ::Tenant.human_attribute_name(:birth_date),
        body: '{{ tenant.birth_date | date_format }}'
      }
    ].freeze

    column_type :default do
      body do |tenant, template_context_cache|
        context = template_context_cache[cache_key(tenant)] ||=
          TemplateContext.new(tenant: tenant, organisation: tenant.organisation).to_h
        @templates[:body]&.render!(context)
      end
    end

    def prefilter
      # @prefilter ||= ::Booking::Filter.new(prefilter_params.presence || {})
    end

    def filter(period = nil)
      # ::Booking::Filter.new(begins_at_after: period&.begin, begins_at_before: period&.end)
    end

    def base_scope
      @base_scope ||= organisation.tenants.ordered
    end
  end
end
