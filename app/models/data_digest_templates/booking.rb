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
  class Booking < ::DataDigestTemplate
    ::DataDigestTemplate.register_subtype self

    DEFAULT_COLUMN_CONFIG = [
      {
        header: ::Booking.human_attribute_name(:ref),
        body: '{{ booking.ref }}'
      },
      {
        header: ::Home.model_name.human,
        body: '{{ booking.home.name }}'
      },
      {
        header: ::Occupancy.human_attribute_name(:begins_at),
        body: '{{ booking.begins_at | datetime_format }}'
      },
      {
        header: ::Occupancy.human_attribute_name(:ends_at),
        body: '{{ booking.ends_at | datetime_format }}'
      },
      {
        header: ::Booking.human_attribute_name(:purpose_description),
        body: "{{ booking.purpose_description }}\n{{ booking.category.title }}"
      },
      {
        header: ::Occupancy.human_attribute_name(:nights),
        body: '{{ booking.nights }}'
      },
      {
        header: ::Tenant.model_name.human,
        body: "{{ booking.tenant.full_name }}\n{{ booking.tenant_organisation }}"
      },
      {
        header: ::Tenant.human_attribute_name(:address),
        body: "{{ booking.tenant.address_lines | join: \"\n\" }}"
      },
      {
        header: ::Tenant.human_attribute_name(:email),
        body: '{{ booking.tenant.email }}'
      },
      {
        header: ::Tenant.human_attribute_name(:phone),
        body: '{{ booking.tenant.phone }}'
      }
    ].freeze

    column_type :default do
      body do |booking|
        context = TemplateContext.new(booking: booking, organisation: booking.organisation)
        @templates[:body]&.render!(context.cached)
      end
    end

    column_type :usage do
      body do |booking|
        tarif = ::Tarif.find_by(id: @config[:tarif_id])
        context = TemplateContext.new(booking: booking, organisation: booking.organisation,
                                      usage: booking.usages.of_tarif(tarif).take)
        @templates[:body]&.render!(context.cached)
      end
    end

    def filter(period = nil)
      ::Booking::Filter.new(prefilter_params.merge(begins_at_after: period&.begin, begins_at_before: period&.end))
    rescue StandardError
      ::Booking::Filter.new
    end

    def base_scope
      @base_scope ||= organisation.bookings.ordered.with_default_includes
    end
  end
end
