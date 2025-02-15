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

module DataDigestTemplates
  class Booking < Tabular
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
        header: ::Booking.human_attribute_name(:begins_at),
        body: '{{ booking.begins_at | datetime_format }}'
      },
      {
        header: ::Booking.human_attribute_name(:ends_at),
        body: '{{ booking.ends_at | datetime_format }}'
      },
      {
        header: ::Booking.human_attribute_name(:purpose_description),
        body: "{{ booking.purpose_description }}\n{{ booking.category.title }}"
      },
      {
        header: ::Booking.human_attribute_name(:nights),
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
      body do |booking, template_context_cache|
        context = template_context_cache[cache_key(booking)] ||=
          TemplateContext.new(booking:, organisation: booking.organisation).to_h
        @templates[:body]&.render!(context)
      end
    end

    column_type :costs do
      body do |booking, template_context_cache|
        costs = CostEstimation.new(booking)
        context = template_context_cache[cache_key(booking, :costs)] ||=
          TemplateContext.new(costs:).to_h
        @templates[:body]&.render!(context)
      end
    end

    column_type :usage do
      body do |booking, template_context_cache|
        tarif = ::Tarif.find_by(id: @config[:tarif_id])
        context = template_context_cache[cache_key(booking, :usage, tarif&.id)] ||=
          TemplateContext.new(usage: booking.usages.of_tarif(tarif).take).to_h
        @templates[:body]&.render!(context)
      end
    end

    column_type :booking_question_response do
      body do |booking, template_context_cache|
        booking_question_id = @config[:booking_question_id] || @config[:id] # TODO: remove legacy id
        response = booking.booking_question_responses.find_by(booking_question_id:)
        context = template_context_cache[cache_key(booking, :booking_question_response, response&.id)] ||=
          TemplateContext.new(booking_question_response: response).to_h
        @templates[:body]&.render!(context)
      end
    end

    def periodfilter(period = nil)
      filter_class.new(begins_at_after: period&.begin, begins_at_before: period&.end)
    end

    def filter_class
      ::Booking::Filter
    end

    def record_order
      { begins_at: :asc, id: :asc }
    end

    def base_scope
      @base_scope ||= organisation.bookings.with_default_includes
    end
  end
end
