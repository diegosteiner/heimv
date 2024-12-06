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
  class Invoice < Tabular
    ::DataDigestTemplate.register_subtype self

    DEFAULT_COLUMN_CONFIG = [
      {
        header: ::Invoice.human_attribute_name(:ref),
        body: '{{ invoice.ref }}'
      },
      {
        header: ::Booking.human_attribute_name(:ref),
        body: '{{ booking.ref }}'
      },
      {
        header: ::Invoice.human_attribute_name(:issued_at),
        body: '{{ invoice.issued_at | datetime_format }}'
      },
      {
        header: ::Invoice.human_attribute_name(:payable_until),
        body: '{{ invoice.payable_until | datetime_format }}'
      },
      {
        header: ::Invoice.human_attribute_name(:amount),
        body: '{{ invoice.amount }}'
      },
      {
        header: ::Invoice.human_attribute_name(:amount_paid),
        body: '{{ invoice.amount_paid }}'
      }
      # {
      #   header: ::Invoice.human_attribute_name(:amount_paid),
      #   body: '{{ invoice.percentage_paid | times: 100 }}%'
      # },
    ].freeze

    column_type :default do
      body do |invoice, template_context_cache|
        booking = invoice.booking
        context = template_context_cache[cache_key(invoice)] ||=
          TemplateContext.new(booking:, invoice:, organisation: booking.organisation).to_h
        @templates[:body]&.render!(context)
      end
    end

    def periodfilter(period = nil)
      filter_class.new(issued_at_after: period&.begin, issued_at_before: period&.end)
    end

    def filter_class
      ::Invoice::Filter
    end

    def base_scope
      @base_scope ||= ::Invoice.joins(:booking).where(bookings: { organisation_id: organisation }).kept
    end
  end
end
