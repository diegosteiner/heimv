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
  class Occupancy < Tabular
    ::DataDigestTemplate.register_subtype self

    DEFAULT_COLUMN_CONFIG = [
      {
        header: ::Occupiable.model_name.human,
        body: '{{ occupancy.occupiable.name }}'
      },
      {
        header: ::Occupancy.human_attribute_name(:occupancy_type),
        body: '{{ occupancy.occupancy_type }}'
      },
      {
        header: ::Occupancy.human_attribute_name(:begins_at),
        body: '{{ occupancy.begins_at | datetime_format }}'
      },
      {
        header: ::Occupancy.human_attribute_name(:ends_at),
        body: '{{ occupancy.ends_at | datetime_format }}'
      },
      {
        header: ::Booking.human_attribute_name(:ref),
        body: '{{ booking.ref }}'
      },
      {
        header: ::Occupancy.human_attribute_name(:remarks),
        body: '{{ occupancy.remarks }}'
      }
    ].freeze

    column_type :default do
      body do |occupancy, template_context_cache|
        context = template_context_cache[cache_key(occupancy)] ||=
          TemplateContext.new(occupancy:, booking: occupancy.booking, organisation: occupancy.organisation).to_h
        @templates[:body]&.render!(context)
      end
    end

    def periodfilter(period = nil)
      filter_class.new(begins_at_after: period&.begin, begins_at_before: period&.end)
    end

    def filter_class
      ::Occupancy::Filter
    end

    def record_order
      { begins_at: :asc, id: :asc }
    end

    def base_scope
      @base_scope ||= ::Occupancy.where(occupiable: organisation.occupiables)
    end
  end
end
